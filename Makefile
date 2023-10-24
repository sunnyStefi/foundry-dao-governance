include .env #source .env on terminal

#to put in order and comment better
.PHONY: push, interaction

push:
	git add .
	git commit -m "test dao process"
	git push origin master


#mif some packeges are already installed -> lazy && operator
install:
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
