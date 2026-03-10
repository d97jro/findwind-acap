RM ?= rm -f
ARCHS = aarch64 armv7hf
.PHONY: docker podman clean

# Container build targets
%.docker %.podman:
	DOCKER_BUILDKIT=1 $(patsubst .%,%,$(suffix $@)) build --build-arg ARCH=$(*F) $(CONTAINER_BUILD_ARGS) -o type=local,dest=. "$(CURDIR)"

dockerbuild: $(addsuffix .docker,$(ARCHS))
podmanbuild: $(addsuffix .podman,$(ARCHS))

clean:
	$(RM) *.eap* *LICENSE.txt
