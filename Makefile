# --------------------------------------------------------------------
# Author(s): Fanani M. Ihsan
#
# This software may be modified and distributed under the terms of the
# MIT license. See the LICENSE file for details.
# --------------------------------------------------------------------

# all our targets are phony (no files to check).
.PHONY: help build

# suppress makes own output
#.SILENT:

# Regular Makefile part for buildpypi itself
help:
	@echo ''
	@echo 'Targets:'
	@echo '  build    	build docker'
	@echo ''

build:
	# only build the container. Note, docker does this also if you apply other targets.
	# docker-compose build $(SERVICE_TARGET)
	bash build_docker.sh
