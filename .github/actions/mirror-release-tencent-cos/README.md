# Mirror Release to Tencent COS

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Mirror Release to Tencent COS
        uses: gpustack/.github/actions/mirror-release-to-tencent-cos@main
```

## Input

```yaml
  tencent-secret-id:
    description: 'Tencent Cloud secret ID which can upload release assets to COS.'
    required: true
  tencent-secret-key:
    description: 'Tencent Cloud secret key which belong to the secret ID.'
    required: true
  tencent-cos-region:
    description: 'Tencent COS region where the bucket belong to.'
    required: false
    default: 'ap-guangzhou'
  tencent-cos-bucket:
    description: 'Tencent COS available bucket ID.'
    required: false
    default: 'gpustack-1303613262'
  max-releases: 
    description: 'Numer of the latest releases to mirror.'
    required: false
    default: '1'
  github-token:
    description: 'Github token to donwload release assets from Github repository, usually inherit from the composition action.'
    required: false
    default: ''
  github-repository:
    description: 'Source Github repository, inform of "owner/name", usually inherit from the composition action.'
    required: false
    default: ''
  dry-run:
    description: 'Skip writing operations.'
    required: false
    default: 'false'
```
