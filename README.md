# azure-digital-resume
- Cloud Resume Challenge inspired https://cloudresumechallenge.dev/
- Frontend built without a framework (js,css)
- Backend API is written in .NET6
- Azure Config:
  - Static website hosted in Storage Account
  - CDN
  - HTTPS for site security
  - DNS points to a custom domain
  - Cosmos DB backend contains site counter

## Setup
- Frontend folder contains the website
- main.js contains visitor counter code.
- Backend contains .net backend
- iac contains terraform deployment
- github actions used to update frontend, backend and terraform



