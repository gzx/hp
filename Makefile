.PHONY : watch build optimize clean npm bower

watch : bower clean
	@echo "开始监视目录变动..."
	@grunt

build : bower clean
	@echo "开始构建项目文件..."
	@grunt build

optimize : bower clean
	@echo "开始构建并压缩项目文件..."
	@grunt optimize

npm :
	@npm install

bower : npm
	@echo "开始检查项目依赖..."
	@node_modules/.bin/bower install

clean:
	@echo "开始清理目录..."
	@rm -rf public

