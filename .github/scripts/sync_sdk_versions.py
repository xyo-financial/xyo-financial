#!/usr/bin/env python3
import os
import re
import sys

def sync_version(sdk_name: str, raw_version: str) -> bool:
    # Normalization mappings for various alias inputs
    alias_map = {
        "golang": "go",
        "csharp": "dotnet",
        "ts": "node",
        "typescript": "node",
        "c++": "cpp",
    }
    cleaned_name = sdk_name.lower().replace("sdk-", "").strip()
    norm_sdk = alias_map.get(cleaned_name, cleaned_name)
    
    # Clean leading 'v' for raw numbers, ensure 'v' for markdown badge
    clean_version = raw_version.lstrip("v").strip()
    v_version = f"v{clean_version}"
    
    print(f"=== Syncing SDK: {norm_sdk} (Input: '{sdk_name}') -> Version: {v_version} ({clean_version}) ===")
    
    targets = ["README.md", "sdk/README.md"]
    modified_files = []
    
    match_patterns = [
        f"sdk-{norm_sdk}",
        f"sdk-{cleaned_name}",
    ]
    if norm_sdk == "go":
        match_patterns.extend(["sdk-go", "sdk-golang"])
        
    for path in targets:
        if not os.path.exists(path):
            print(f"Warning: {path} not found.")
            continue
            
        with open(path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        new_lines = []
        file_updated = False
        
        for line in lines:
            if any(p in line for p in match_patterns):
                orig = line
                # 1. Update version badge `vX.Y.Z` or `vX.Y.Z-something`
                line = re.sub(r"`v[0-9]+\.[0-9]+[^`]*`", f"`{v_version}`", line)
                # 2. Update Java maven coordinates xyo-sdk:X.Y.Z
                line = re.sub(r"xyo-sdk:[0-9]+\.[0-9]+[^\`\s|]*", f"xyo-sdk:{clean_version}", line)
                
                if line != orig:
                    file_updated = True
                    print(f"[{path}] Updated:\n  - Before: {orig.strip()}\n  + After:  {line.strip()}")
                    
            new_lines.append(line)
            
        if file_updated:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(new_lines)
            modified_files.append(path)
            print(f"Successfully wrote updates to {path}")
        else:
            print(f"No version changes needed or pattern not matched in {path}")
            
    return len(modified_files) > 0

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 sync_sdk_versions.py <sdk_name> <version>")
        sys.exit(1)
        
    sdk_arg = sys.argv[1]
    ver_arg = sys.argv[2]
    sync_version(sdk_arg, ver_arg)
