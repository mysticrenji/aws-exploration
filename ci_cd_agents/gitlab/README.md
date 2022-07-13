The Installation of GitLab Runner is done via Helm Charts

```
helm repo add gitlab https://charts.gitlab.io
helm install  gitlab-runner -f [Valuefile] gitlab/gitlab-runner
```