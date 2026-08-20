{pkgs, lib, ...}: {
  home.packages = with pkgs; [
    (lib.hiPrio kubectl)
    k9s
    kubernetes-helm
    kustomize
    awscli2
    minikube
  ];

  programs.fish = {
	  shellAliases = {
		  k = "kubectl";
	  };
  };
}
