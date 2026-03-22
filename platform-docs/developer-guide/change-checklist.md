# GitOps Change Checklist

Use this before merging any platform change.

## Paths and structure

- [ ] All referenced files exist in Git.
- [ ] `platform-helm` paths match current directory layout.
- [ ] AppSet list entries point to the correct values files.

## Environment parity

- [ ] Dev and prod updates are intentional (and documented if different).
- [ ] New services/components are added to both env appsets where required.
- [ ] Preview behavior for new services is explicitly handled.

## Safety and ordering

- [ ] Sync wave choices are deliberate and do not break startup ordering.
- [ ] Prune behavior implications are understood for removed components.
- [ ] Stateful changes include migration/backup plan.

## Validation

- [ ] YAML validates locally.
- [ ] Argo appset templates render with no missing value file errors.
- [ ] CI workflows that copy/update values still reference valid paths.

## Documentation

- [ ] `platform-docs/developer-guide/path-reference.md` updated if paths changed.
- [ ] Relevant runbook updated (`add-microservice`, `preview-environments`, etc.).
