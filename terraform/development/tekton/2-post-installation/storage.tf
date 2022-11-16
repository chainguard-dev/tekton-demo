resource "kubernetes_storage_class_v1" "regional_sc" {
  metadata {
    name = "regionalpd-storageclass"
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy      = "Retain"
  parameters = {
    type             = "pd-standard"
    replication-type = "regional-pd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}
