{pkgs, inputs, ...}: 
{
  home.packages = [
	pkgs.nodejs
	pkgs.bun
  ];
}
