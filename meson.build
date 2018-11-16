project('hunt-database', 'd',
    meson_version: '>=0.46',
    license: 'Apache-2.0',

    version: '1.0.0'
)

project_soversion = '0'

hunt_sql_required_version = '>= 1.0.0'

src_dir = include_directories('source/')
pkgc = import('pkgconfig')

database_src = [
    'source/hunt/database/Database.d',
    'source/hunt/database/Defined.d',
    'source/hunt/database/driver/Connection.d',
    'source/hunt/database/driver/Dialect.d',
    'source/hunt/database/driver/Expression.d',
    'source/hunt/database/driver/Factory.d',
    'source/hunt/database/driver/ResultSet.d',
    'source/hunt/database/driver/mysql/Binding.d',
    'source/hunt/database/driver/mysql/Connection.d',
    'source/hunt/database/driver/mysql/Dialect.d',
    'source/hunt/database/driver/mysql/ResultSet.d',
    'source/hunt/database/driver/postgresql/Binding.d',
    'source/hunt/database/driver/postgresql/Connection.d',
    'source/hunt/database/driver/postgresql/Dialect.d',
    'source/hunt/database/driver/postgresql/ResultSet.d',
    'source/hunt/database/driver/sqlite/Binding.d',
    'source/hunt/database/driver/sqlite/Connection.d',
    'source/hunt/database/driver/sqlite/Dialect.d',
    'source/hunt/database/driver/sqlite/ResultSet.d',
    'source/hunt/database/query/Common.d',
    'source/hunt/database/query/Comparison.d',
    'source/hunt/database/query/Expr.d',
    'source/hunt/database/query/package.d',
    'source/hunt/database/query/QueryBuilder.d',
    'source/hunt/database/Option.d',
    'source/hunt/database/DatabaseException.d',
    'source/hunt/database/package.d',
    'source/hunt/database/Pool.d',
    'source/hunt/database/Row.d',
    'source/hunt/database/Statement.d',
    'source/hunt/database/Transaction.d',
    'source/hunt/database/Url.d',
    'source/hunt/database/Utils.d'
]
install_subdir('source/hunt/', install_dir: 'include/d/hunt-database/')

# determine the right version flag for the compiler we use
dc = meson.get_compiler('d')
dc_version_arg = '-fversion='
if dc.get_id() == 'llvm'
    dc_version_arg = '-d-version='
elif dc.get_id() == 'dmd'
    dc_version_arg = '-version='
endif

# construct a bunch of libraries for each selected driver
foreach driver : get_option('drivers')
    if driver == 'postgres'
        pq_dep = dependency('libpq', version: '>= 11.0')
        lib_deps = [pq_dep]

        lib_name = 'hunt-database-postgres'
        version_flags = ['USE_POSTGRESQL']
        lib_description = 'Database abstraction layer for D - Built for PostgreSQL.'

    elif driver == 'mysql'
        mysql_dep = dependency('mysqlclient', required: false)
        if not mysql_dep.found()
            warning('Unable to find libmysqlclient, continuing anyway, assuming it exists.')
            mysql_dep = declare_dependency(link_args: '-lmysqlclient')
        endif
        lib_deps = [mysql_dep]

        lib_name = 'hunt-database-mysql'
        version_flags = ['USE_MYSQL']
        lib_description = 'Database abstraction layer for D - Built for MySQL.'

    elif driver == 'sqlite'
        sqlite_dep = dependency('sqlite3')
        lib_deps = [sqlite_dep]

        lib_name = 'hunt-database-sqlite'
        version_flags = ['USE_SQLITE']
        lib_description = 'Database abstraction layer for D - Built for SQLite.'

    elif driver == 'multi'
        pq_dep = dependency('libpq', version: '>= 9.6')
        sqlite_dep = dependency('sqlite3')

        if not mysql_dep.found()
            warning('Unable to find libmysqlclient, continuing anyway, assuming it exists.')
            mysql_dep = declare_dependency(link_args: '-lmysqlclient')
        endif
        lib_deps = [pq_dep, mysql_dep, sqlite_dep]

        lib_name = 'hunt-database-multi'
        version_flags = ['USE_POSTGRESQL', 'USE_MYSQL', 'USE_SQLITE']
        lib_description = 'Database abstraction layer for D - Built for all supported database drivers.'

    else
        error('Unknown driver selected!')
    endif


    db_lib = library(lib_name,
        [database_src],
        include_directories: [src_dir],
        dependencies: lib_deps,
        install: true,
        version: meson.project_version(),
        soversion: project_soversion,
        d_module_versions: version_flags
    )

    pkgc.generate(name: lib_name,
        libraries: db_lib,
        subdirs: 'd/hunt-database/',
        version: meson.project_version(),
        d_module_versions: version_flags,
        description: lib_description
    )

    ver_dc_args = []
    foreach v : version_flags
        ver_dc_args += [dc_version_arg + v]
    endforeach


    # this dumb code repetition exists to allow other Meson projects to embed this as subproject easily,
    # and to achieve that we need to declare dependencies with different variable names.
    if driver == 'postgres'
        hdb_postgres_dep = declare_dependency(
            link_with: [db_lib],
            include_directories: [src_dir],
            compile_args: ver_dc_args
        )

    elif driver == 'mysql'
        hdb_mysql_dep = declare_dependency(
            link_with: [db_lib],
            include_directories: [src_dir],
            compile_args: ver_dc_args
        )

    elif driver == 'sqlite'
        hdb_sqlite_dep = declare_dependency(
            link_with: [db_lib],
            include_directories: [src_dir],
            compile_args: ver_dc_args
        )

    elif driver == 'multi'
        hdb_multi_dep = declare_dependency(
            link_with: [db_lib],
            include_directories: [src_dir],
            compile_args: ver_dc_args
        )

    endif

endforeach
