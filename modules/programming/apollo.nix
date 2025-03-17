{pkgs, ...}: {
  home.packages = [
    pkgs.rover
    pkgs.zulu17
    (pkgs.google-cloud-sdk.withExtraComponents [
    	pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
	pkgs.google-cloud-sdk.components.kubectl
    ])
  ];
}
