{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    k9s
    helm
    kustomize
    awscli2
  ];

  programs.fish = {
	  shellAliases = {
		  k = "kubectl";
	  };
  };
}