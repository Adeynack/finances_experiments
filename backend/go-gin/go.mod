module github.com/adeynack/finances-service-go

go 1.13 // when changing this, update also the GO version in `.travis.yml`.

require (
	github.com/Azure/go-ansiterm v0.0.0-20170929234023-d6e3b3328b78 // indirect
	github.com/DATA-DOG/go-sqlmock v1.3.3 // indirect
	github.com/Microsoft/go-winio v0.4.11 // indirect
	github.com/containerd/containerd v1.2.7 // indirect
	github.com/cosiner/argv v0.0.1 // indirect
	github.com/docker/distribution v2.7.0+incompatible // indirect
	github.com/docker/docker v0.7.3-0.20190817195342-4760db040282 // indirect
	github.com/docker/go-connections v0.4.0 // indirect
	github.com/docker/go-units v0.3.3 // indirect
	github.com/friendsofgo/errors v0.9.2
	github.com/gin-contrib/sse v0.0.0-20170109093832-22d885f9ecc7 // indirect
	github.com/gin-gonic/gin v1.3.0
	github.com/go-delve/delve v1.3.2 // indirect
	github.com/go-http-utils/headers v0.0.0-20181008091004-fed159eddc2a
	github.com/gofrs/uuid v3.2.0+incompatible // indirect
	github.com/golang-migrate/migrate v3.5.4+incompatible
	github.com/gorilla/mux v1.7.1 // indirect
	github.com/json-iterator/go v1.1.7 // indirect
	github.com/kat-co/vala v0.0.0-20170210184112-42e1d8b61f12
	github.com/konsorten/go-windows-terminal-sequences v1.0.2 // indirect
	github.com/lib/pq v1.0.0
	github.com/mattn/go-colorable v0.1.4 // indirect
	github.com/mattn/go-isatty v0.0.10 // indirect
	github.com/mattn/go-runewidth v0.0.6 // indirect
	github.com/morikuni/aec v0.0.0-20170113033406-39771216ff4c // indirect
	github.com/olebedev/config v0.0.0-20180910155717-57f804269e64
	github.com/opencontainers/go-digest v1.0.0-rc1 // indirect
	github.com/opencontainers/image-spec v1.0.1 // indirect
	github.com/peterh/liner v1.1.0 // indirect
	github.com/pkg/errors v0.8.1 // indirect
	github.com/sirupsen/logrus v1.4.2
	github.com/spf13/cobra v0.0.5 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/spf13/viper v1.4.0
	github.com/stretchr/testify v1.3.0
	github.com/toorop/gin-logrus v0.0.0-20180629064933-5d05462a6ed8
	github.com/volatiletech/inflect v0.0.0-20170731032912-e7201282ae8d // indirect
	github.com/volatiletech/null v8.0.0+incompatible
	github.com/volatiletech/sqlboiler v3.6.0+incompatible
	go.starlark.net v0.0.0-20191021185836-28350e608555 // indirect
	golang.org/x/arch v0.0.0-20191101135251-a0d8588395bd // indirect
	golang.org/x/net v0.0.0-20191009170851-d66e71096ffb // indirect
	golang.org/x/sys v0.0.0-20191105231009-c1f44814a5cd // indirect
	google.golang.org/genproto v0.0.0-20190425155659-357c62f0e4bb // indirect
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/validator.v8 v8.18.2 // indirect
	gopkg.in/yaml.v2 v2.2.5 // indirect
	gotest.tools v2.2.0+incompatible // indirect
)

replace github.com/ugorji/go v1.1.4 => github.com/ugorji/go/codec v0.0.0-20190204201341-e444a5086c43
