import os
import sys
from huggingface_hub import HfApi

# 1. Configuration
HF_USERNAME = "verma89" 
SPACE_NAME = "predictive-maintenance-service"
REPO_ID = f"{HF_USERNAME}/{SPACE_NAME}"

# Read token passed from the terminal argument
if len(sys.argv) < 2:
    print("❌ Error: Missing Hugging Face token argument.")
    sys.exit(1)
    
HF_TOKEN = sys.argv[1]

# 2. Initialize the Hugging Face API with explicit token credentials
api = HfApi(token=HF_TOKEN)

print(f"🚀 Initializing Space deployment for: {REPO_ID}")

try:
    # 3. Create the Space repository
    api.create_repo(
        repo_id=REPO_ID,
        repo_type="space",
        space_sdk="docker",
        exist_ok=True
    )
    print(f"✅ Space repository verified/created successfully.")

    # 4. Upload your deployment files from Colab into the Space
    print("📤 Uploading deployment files to Hugging Face...")
    
    api.upload_file(
        path_or_fileobj="requirements.txt",
        path_in_repo="requirements.txt",
        repo_id=REPO_ID,
        repo_type="space",
        token=HF_TOKEN
    )
    
    api.upload_file(
        path_or_fileobj="Dockerfile",
        path_in_repo="Dockerfile",
        repo_id=REPO_ID,
        repo_type="space",
        token=HF_TOKEN
    )
    
    if os.path.exists("app"):
        api.upload_folder(
            folder_path="app",
            path_in_repo="app",
            repo_id=REPO_ID,
            repo_type="space",
            token=HF_TOKEN
        )
        
    print(f"🎉 Success! Your files have been pushed to https://huggingface.co/spaces/{REPO_ID}")

except Exception as e:
    print(f"❌ Deployment failed: {e}")
