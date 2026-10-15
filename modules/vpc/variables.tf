variable "project_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" {
  type        = list(string)
  description = "Two distinct Availability Zones."
  validation {
    condition     = length(var.azs) == 2 && var.azs[0] != var.azs[1]
    error_message = "Exactly two distinct Availability Zones are required."
  }
}
