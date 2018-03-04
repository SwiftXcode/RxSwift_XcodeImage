# Makefile
# Copyright © 2018 ZeeZide GmbH. All rights reserved.

-include config.make

PACKAGE = RxSwift
MAJOR=0
MINOR=1
SUBMINOR=0

PACKAGE_TARBALL_NAME=$(PACKAGE)-$(MAJOR).$(MINOR).$(SUBMINOR).image
PACKAGE_TARBALL_LATEST=$(PACKAGE).image
PACKAGE_TARBALL=$(SWIFT_BUILD_DIR)/$(PACKAGE_TARBALL_LATEST)

PROJECT_APP_TEMPLATES_DIR = templates/Project\ Templates/Application


# entry points

all : build-image

clean : clean-image

distclean : clean
	rm -rf .build Package.resolved


install : all install-templates install-image

uninstall : uninstall-templates uninstall-image

lint : lint-templates

# image

# SWIFT_XCODE_IMAGING=yes swift xcode build
# FIXME: we need to build the image for iOS!!!
build-image :
	SA_IMAGE=$(PACKAGE) swift xcode image

clean-image:
	swift xcode clean

install-image: all make-abi-install-dir
	$(INSTALL) $(PACKAGE_TARBALL) $(SWIFT_ABI_LIB_INSTALL_DIR)/$(PACKAGE_TARBALL_NAME)
	( cd $(SWIFT_ABI_LIB_INSTALL_DIR); \
	  ln -sf $(PACKAGE_TARBALL_NAME) $(PACKAGE_TARBALL_LATEST) )

uninstall-image:
	rm -f "$(SWIFT_ABI_LIB_INSTALL_DIR)/$(PACKAGE_TARBALL_NAME)"
	rm -f "$(SWIFT_ABI_LIB_INSTALL_DIR)/$(PACKAGE_TARBALL_LATEST)"

make-abi-install-dir :
	$(MKDIR_P) $(SWIFT_ABI_LIB_INSTALL_DIR)


# templates
#
#   this is a little crappy, but I couldn't figure our how to deal properly
#   with spaces in Makefiles ;-)

lint-templates :
	$(XML_LINTER) $(PROJECT_APP_TEMPLATES_DIR)/RxSwift\ App.xctemplate/TemplateInfo.plist

install-templates : lint-templates \
	install-project-app-templates
	swift-xcode-link-templates --replacedirs

uninstall-templates : \
	uninstall-project-app-templates
	swift-xcode-link-templates --deletelinks

install-project-app-templates : uninstall-project-app-templates
	$(MKDIR_P) $(XCODE_TEMPLATE_PROJECT_APP_SOURCE_DIR)
	$(INSTALL_R) \
		$(PROJECT_APP_TEMPLATES_DIR)/RxSwift\ App.xctemplate \
		$(XCODE_TEMPLATE_PROJECT_APP_SOURCE_DIR)/
	$(INSTALL_R) \
		$(XCODE_IPHONEOS_TEMPLATES_APP_SINGLE_VIEW)/Main.storyboard \
		$(XCODE_TEMPLATE_PROJECT_APP_SOURCE_DIR)/RxSwift\ App.xctemplate/

uninstall-project-app-templates :
	$(UNINSTALL_R) \
		$(XCODE_TEMPLATE_PROJECT_APP_SOURCE_DIR)/RxSwift\ App.xctemplate

