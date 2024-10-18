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
inputs:
  region:
    description: 'Tencent COS region where the bucket belong to.'
    required: true
  bucket:
    description: 'Tencent COS available bucket ID.'
    required: true
  secret-id:
    description: 'Tencent Cloud secret ID which can write COS.'
    required: true
  secret-key:
    description: 'Tencent Cloud secret key which belong to the secret ID.'
    required: true
  max-releases: 
    description: 'Numer of the latest releases to mirror.'
    required: false
    default: '1'
  github-token:
    description: 'The Github token to donwload releases from Github repository, usually inherit from the composition action.'
    required: false
    default: ''
  github-repository:
    description: 'The target Github repository, inform of "owner/name", usually inherit from the composition action.'
    required: false
    default: ''
  dry-run:
    description: 'Skip writing operations.'
    required: false
    default: 'false'
```
