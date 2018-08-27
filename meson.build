project('hunt-database', 'd',
    meson_version: '>=0.46',
    license: 'Apache-2.0',

    version: '0.1.8'
)

project_soversion = '0'

src_dir = include_directories('source/')
pkgc = import('pkgconfig')

database_src = [
    'source/database/database.d',
    'source/database/defined.d',
    'source/database/driver/builder.d',
    'source/database/driver/connection.d',
    'source/database/driver/dialect.d',
    'source/database/driver/expression.d',
    'source/database/driver/factory.d',
    'source/database/driver/mysql/binding.d',
    'source/database/driver/mysql/builder.d',
    'source/database/driver/mysql/connection.d',
    'source/database/driver/mysql/dialect.d',
    'source/database/driver/mysql/resultset.d',
    'source/database/driver/mysql/syntax.d',
    'source/database/driver/postgresql/binding.d',
    'source/database/driver/postgresql/builder.d',
    'source/database/driver/postgresql/connection.d',
    'source/database/driver/postgresql/dialect.d',
    'source/database/driver/postgresql/resultset.d',
    'source/database/driver/postgresql/syntax.d',
    'source/database/driver/resultset.d',
    'source/database/driver/sqlite/binding.d',
    'source/database/driver/sqlite/builder.d',
    'source/database/driver/sqlite/connection.d',
    'source/database/driver/sqlite/dialect.d',
    'source/database/driver/sqlite/resultset.d',
    'source/database/driver/sqlite/syntax.d',
    'source/database/driver/syntax.d',
    'source/database/exception.d',
    'source/database/option.d',
    'source/database/package.d',
    'source/database/pool.d',
    'source/database/row.d',
    'source/database/statement.d',
    'source/database/transaction.d',
    'source/database/url.d',
    'source/database/utils.d'
]
install_subdir('source/database', install_dir: 'include/d/hunt-database/')

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
        pq_dep = dependency('libpq', version: '>= 9.6')
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
