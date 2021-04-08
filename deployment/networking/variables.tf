variable "namespaces" {
    type = map(string)
    description = "networking namespaces"
    default = {
        "metallb" = "metallb-system"
    }
}