output "rds_instance_address" {
  value       = module.rds.db_instance_address
  description = "DataBase Instance address"
}

output "rds_db_sg" {
  value = module.RDS_SG.security_group_id
}