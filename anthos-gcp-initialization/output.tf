output "cluster-name" {
  value   = [for i in range(length(module.cluster)) : module.cluster[tostring(i)].name]
  description = "All clusters names"
}

//output "clusters-info" {
//  value   = module.cluster
//  sensitive = true
//  description = "All clusters info"
//}

