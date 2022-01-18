variable "web_instance_type_map" {
  type = map(string)
  default = {
    stage = "t2.micro"
    prod  = "t3.large"
  }
}

variable "web_instance_count_map" {
  type = map(number)
  default = {
    stage = 1
    prod  = 2
  }
}

variable "instances" {
  type = set(string)
  default = [
    "server01",
    "server02"
  ]
}

