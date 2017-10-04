INSTALL_DIR  = /usr/local/bin
MANPAGE_DIR  = /usr/local/share/man/man1
XCODE_CONFIG = Release
XCODE_TARGET = SMCKitTool
XCODE_BUILD  = xcodebuild -target ${XCODE_TARGET}

.PHONY: install machine release debug build uninstall jazzy ronn clean distclean

install: machine release
	cp bin/smckit ${INSTALL_DIR}
	cp docs/smckit.1 ${MANPAGE_DIR}
	du -sh ${INSTALL_DIR}/smckit
machine:
	@sysctl hw.model;                                             \
	 sw_vers;                                                     \
	 uname -v;                                                    \
	 ioreg -lbrc AppleSMC | grep smc-version | tr -d "|" | xargs; \
	 xcodebuild -version;                                         \
	 swiftc -v
release: build
	strip bin/smckit
debug: XCODE_CONFIG=Debug
debug: build
build: SMCKitTool/lib/CommandLine/README.md
	${XCODE_BUILD} -configuration ${XCODE_CONFIG} build
	mkdir -p bin
	cp build/${XCODE_CONFIG}/SMCKitTool bin/smckit
SMCKitTool/lib/CommandLine/README.md:
	git submodule update --init
uninstall:
	rm ${INSTALL_DIR}/smckit
	rm ${MANPAGE_DIR}/smckit.1
jazzy:
	jazzy -a beltex -u http://beltex.github.io -m SMCKit \
          -g https://github.com/beltex/SMCKit
ronn:
	ronn --style=toc docs/smckit.1.ronn
	mv docs/smckit.1.html docs/index.html
clean:
	${XCODE_BUILD} -configuration Debug clean
	${XCODE_BUILD} -configuration Release clean
distclean:
	rm -rf bin build
