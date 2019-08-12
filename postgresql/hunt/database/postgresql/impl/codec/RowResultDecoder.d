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

module hunt.database.postgresql.impl.codec.RowResultDecoder;

import hunt.database.base.Row;
import hunt.database.postgresql.impl.RowImpl;
import io.netty.buffer.ByteBuf;
import hunt.database.base.impl.RowDecoder;

import java.util.function.BiConsumer;
import java.util.stream.Collector;

class RowResultDecoder!(C, R) implements RowDecoder {

  final Collector!(Row, C, R) collector;
  final boolean singleton;
  final BiConsumer!(C, Row) accumulator;
  final PgRowDesc desc;

  private int size;
  private C container;
  private Row row;

  RowResultDecoder(Collector!(Row, C, R) collector, boolean singleton, PgRowDesc desc) {
    this.collector = collector;
    this.singleton = singleton;
    this.accumulator = collector.accumulator();
    this.desc = desc;
  }

  int size() {
    return size;
  }

  override
  void decodeRow(int len, ByteBuf in) {
    if (container is null) {
      container = collector.supplier().get();
    }
    if (singleton) {
      if (row is null) {
        row = new RowImpl(desc);
      } else {
        row.clear();
      }
    } else {
      row = new RowImpl(desc);
    }
    Row row = new RowImpl(desc);
    for (int c = 0; c < len; ++c) {
      int length = in.readInt();
      Object decoded = null;
      if (length != -1) {
        PgColumnDesc columnDesc = desc.columns[c];
        if (columnDesc.dataFormat == DataFormat.BINARY) {
          decoded = DataTypeCodec.decodeBinary(columnDesc.dataType, in.readerIndex(), length, in);
        } else {
          decoded = DataTypeCodec.decodeText(columnDesc.dataType, in.readerIndex(), length, in);
        }
        in.skipBytes(length);
      }
      row.addValue(decoded);
    }
    accumulator.accept(container, row);
    size++;
  }

  R complete() {
    if (container is null) {
      container = collector.supplier().get();
    }
    return collector.finisher().apply(container);
  }

  void reset() {
    container = null;
    size = 0;
  }
}
