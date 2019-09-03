/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
module hunt.database.mysql.impl.codec.MySQLRowDesc;

import hunt.database.mysql.impl.codec.ColumnDefinition;

import hunt.database.base.impl.RowDesc;

import std.algorithm;
import std.range;

class MySQLRowDesc : RowDesc {

    private ColumnDefinition[] _columnDefinitions;
    private DataFormat _dataFormat;

    this(ColumnDefinition[] columnDefinitions, DataFormat dataFormat) {
        super(columns.map!(d => d.name).array);
        this._columnDefinitions = columnDefinitions;
        this._dataFormat = dataFormat;
    }

    ColumnDefinition[] columnDefinitions() {
        return _columnDefinitions;
    }

    DataFormat dataFormat() {
        return _dataFormat;
    }
}
