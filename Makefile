######
##  Default configuration
##
## Modify this configuration by creating a local.config file and resetting the
## variables there. See local.config.sample for an example and a description
## of all used variables.

include project.config

MODE = RELEASE

PROG_EXT =

ifeq ($(OS),Windows_NT)
	PROG_EXT = .exe
endif

CPP = g++
CPPFLAGS += -Wall -Wextra -Iinclude
CPPFLAGS_DEBUG += -g
CPPFLAGS_RELEASE += -O2 -DNDEBUG

LD = g++
LDFLAGS += 
LDFLAGS_DEBUG +=
LDFLAGS_RELEASE += 
LIBS += $(LIBRARIES)

DIST_NAME = $(PROG_NAME)-$(PROG_VERSION)
DIST_CONTENT = $(TARGET) $(DIST_FILES)

BIN = bin
SRC = src
INC = include
BUILD = build
DIST = dist

-include local.config

# Set build mode specific variables
CPPFLAGS += $(CPPFLAGS_$(MODE))
LDFLAGS += $(LDFLAGS_$(MODE))

######
##  File lists

SRC_FILES = $(wildcard $(SRC)/*.cpp)
OBJ_FILES = $(patsubst $(SRC)/%.cpp,$(BUILD)/%.o,$(SRC_FILES))
DEP_FILES = $(patsubst $(SRC)/%.cpp,$(BUILD)/%.d,$(SRC_FILES))

TARGET = $(BIN)/$(PROG_NAME)$(PROG_EXT)
DIST_TARGET = $(DIST)/$(DIST_NAME)
DIST_ARCHIVE = $(DIST)/$(DIST_NAME).tar.gz

######
##  Targets

all: $(TARGET)

help:
	@echo Use 'make' to create $(TARGET)
	@echo Special targets:
	@echo "  dist           - Create $(DIST_TARGET) with all needed files"
	@echo "  dist-archive   - Create $(DIST_ARCHIVE) from $(DIST_TARGET)"
	@echo "  mkinfo         - List makefile itnernals"
	@echo "  help           - Show this help message"

# Dependency file creation
$(BUILD)/%.d: $(SRC)/%.cpp
	@$(CPP) $(CPPFLAGS) -MM -MT $(patsubst $(SRC)/%.cpp,$(BUILD)/%.o,$<) $< > $@

# Object creation
$(BUILD)/%.o:
	@echo Compiling $@
	@$(CPP) $(CPPFLAGS) -c $< -o $@
	
# Target
$(TARGET): $(OBJ_FILES)
	@echo Linking $@
	@$(LD) $(LDFLAGS) $(OBJ_FILES) $(LIBS) -o $(TARGET)

-include $(DEP_FILES)

dist: $(DIST_TARGET)

$(DIST_TARGET): $(TARGET)
	@$(RM) -r $(DIST)/$(DIST_NAME)
	@mkdir $(DIST)/$(DIST_NAME)
	@cp $(DIST_CONTENT) $(DIST)/$(DIST_NAME)
	
dist-archive: $(DIST_ARCHIVE)

$(DIST_ARCHIVE): $(DIST_TARGET)
	@echo Creating $@
	@$(RM) $(DIST_ARCHIVE)
	@tar -czf $(DIST_ARCHIVE) -C $(DIST) $(DIST_NAME)
	
clean:
	@$(RM) $(OBJ_FILES) $(DEP_FILES)

distclean: clean
	@$(RM) $(TARGET)
	@$(RM) -r $(DIST_TARGET)
	@$(RM) $(DIST_ARCHIVE)

mkinfo:
	@echo Make Variables
	@echo ==============
	@echo MODE = $(MODE)
	@echo
	@echo CPP = $(CPP)
	@echo CPPFLAGS = $(CPPFLAGS)
	@echo LD = $(LD)
	@echo LDFLAGS = $(LDFLAGS)
	@echo
	@echo Files
	@echo =====
	@echo Source files:
	@echo "    $(SRC_FILES)"
	@echo Dependency files:
	@echo "    $(DEP_FILES)"
	@echo Object files:
	@echo "    $(OBJ_FILES)"
	@echo 
	@echo Distribution
	@echo ============
	@echo Target directory: $(DIST)/$(DIST_NAME)
	@echo Files to copy:
	@echo "    $(DIST_CONTENT)"
	
.PHONY: clean distclean mkinfo help
