output "all_ns" {
  value   = kubernetes_namespace.example
  description = "All about new ns"
}

output "all_wl" {
  value   = module.my-app-workload-identity
  description = "All about new wl"
}