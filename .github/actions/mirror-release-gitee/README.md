# Mirror Release to Gitee

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Mirror Release to Gitee
        uses: gpustack/.github/actions/mirror-release-to-gitee@main
```

## Input

```yaml
inputs:
  gitee-username:
    description: 'Gitee username to upload release assets.'
    required: true
  gitee-token:
    description: 'Gitee token to upload release assets.'
    required: true
  gitee-repository:
    description: 'Target Gitee repository, inform of "owner/name", usually the same as Source Github repository.'
    required: false
    default: ''
  max-releases: 
    description: 'Numer of the latest releases to mirror.'
    required: false
    default: '1'
  github-token:
    description: 'Github token to donwload releases from Github repository, usually inherit from the composition action.'
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
