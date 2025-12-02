import os
import json
import re

import boto3
import pandas as pd
from huggingface_hub import hf_hub_download, list_repo_files
from dotenv import load_dotenv

load_dotenv()

def main():
    repo_id = "gwenshap/sales-transcripts"

    # Setup S3 client
    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_DEFAULT_REGION", "us-east-1"),
    )

    bucket = "sentiment-ai-mab"
    prefix = "transcripts/sales-transcripts"

    # List all CSV files in the dataset
    print("Listing files in dataset...")
    files = list_repo_files(repo_id, repo_type="dataset")
    csv_files = [f for f in files if f.endswith(".csv")]

    print(f"Found {len(csv_files)} CSV files")

    for idx, csv_file in enumerate(csv_files):
        print(f"Processing ({idx+1}/{len(csv_files)}): {csv_file}")

        # Download the file
        local_path = hf_hub_download(
            repo_id=repo_id,
            filename=csv_file,
            repo_type="dataset"
        )

        # Read CSV
        df = pd.read_csv(local_path)

        # Extract company prefix from filename (e.g., "nexiv-solutions" from "nexiv-solutions__2_transcript.csv")
        base_name = os.path.basename(csv_file)
        match = re.match(r"(.+?)__(\d+)_transcript\.csv", base_name)
        if match:
            company = match.group(1)
            transcript_num = match.group(2)
            output_filename = f"{transcript_num}_transcript.json"
        else:
            company = "other"
            output_filename = base_name.replace(".csv", ".json")

        # Transform records: only keep text, id, speaker
        transformed = []
        for _, row in df.iterrows():
            record = {
                "text": row.get("Text", ""),
                "id": int(row.get("Chunk_id", 0)),
                "speaker": row.get("Speaker", ""),
            }
            transformed.append(record)

        # Upload to S3 with company as subdirectory
        key = f"{prefix}/{company}/{output_filename}"

        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(transformed, indent=2),
            ContentType="application/json",
        )

        print(f"  -> Uploaded to s3://{bucket}/{key}")

    print(f"\nDone! All transcripts uploaded to s3://{bucket}/{prefix}/")

if __name__ == "__main__":
    main()
