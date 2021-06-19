COMMON=default_env.tres export_presets.cfg project.godot

CLIENT_TEMPLATE=build/godot/Godot_v3.2.3-stable_x11.64
SERVER_TEMPLATE=build/godot/Godot_v3.2.3-stable_linux_server.64
EXPORTER=build/godot/Godot_v3.2.3-stable_linux_headless.64

.PHONY: all

all: build/client build/server

$(CLIENT_TEMPLATE): |build/godot
	wget -O build/godot/tmp.zip 'https://downloads.tuxfamily.org/godotengine/3.2.3/Godot_v3.2.3-stable_x11.64.zip'
	cd build/godot && unzip tmp.zip
	rm -f build/godot/tmp.zip

$(SERVER_TEMPLATE): |build/godot
	wget -O build/godot/tmp.zip 'https://downloads.tuxfamily.org/godotengine/3.2.3/Godot_v3.2.3-stable_linux_server.64.zip'
	cd build/godot && unzip tmp.zip
	rm -f build/godot/tmp.zip

$(EXPORTER): |build/godot
	wget -O build/godot/tmp.zip 'https://downloads.tuxfamily.org/godotengine/3.2.3/Godot_v3.2.3-stable_linux_headless.64.zip'
	cd build/godot && unzip tmp.zip
	rm -f build/godot/tmp.zip

build/godot:
	mkdir -p build/godot

build/client: $(CLIENT_TEMPLATE) $(EXPORTER) client $(COMMON) |build
	$(EXPORTER) --export "Client" "build/client"

build/server: $(SERVER_TEMPLATE) $(EXPORTER) server $(COMMON) |build
	$(EXPORTER) --export "Server" "build/server"
