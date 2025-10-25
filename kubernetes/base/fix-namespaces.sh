# fix-all-namespaces.sh
#!/bin/bash
echo "Removing hardcoded namespaces from all Kubernetes manifests..."

# Remove namespace from all YAML files in kubernetes/base/
find kubernetes/base/ -name "*.yaml" -type f | while read file; do
    echo "Fixing $file"
    # Remove namespace lines but keep the file structure
    sed -i '/namespace: app-stack/d' "$file"
done

echo "✅ All hardcoded namespaces removed!"