locals {
  microservices = toset([
    "api-gateway",
    "reader",
    "writer",
  ])

  common_tags = {
    Project     = "platform-engineering-project"
    ManagedBy   = "terraform"
    Environment = "testing"
  }
}