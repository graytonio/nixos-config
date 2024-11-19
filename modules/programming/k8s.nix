{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    k9s
    kubernetes-helm
    kustomize
    awscli2
  ];

  programs.fish = {
	  shellAliases = {
		  k = "kubectl";
	  };
  };
}
