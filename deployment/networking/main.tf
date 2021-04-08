module "metallb" {
    source = "./metallb"
    namespace = var.namespaces.metallb
}