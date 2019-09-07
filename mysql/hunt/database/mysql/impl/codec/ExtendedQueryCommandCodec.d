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
module hunt.database.mysql.impl.codec.ExtendedQueryCommandCodec;

import hunt.database.mysql.impl.codec.CommandType;
import hunt.database.mysql.impl.codec.DataFormat;
import hunt.database.mysql.impl.codec.ExtendedQueryCommandBaseCodec;
import hunt.database.mysql.impl.codec.MySQLEncoder;
import hunt.database.mysql.impl.codec.MySQLRowDesc;
import hunt.database.mysql.impl.codec.Packets;
import hunt.database.mysql.impl.codec.QueryCommandBaseCodec;
import hunt.database.mysql.impl.codec.RowResultDecoder;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.database.base.impl.command.ExtendedQueryCommand;

import hunt.database.mysql.impl.codec.Packets;

/**
 * 
 */
class ExtendedQueryCommandCodec(R) : ExtendedQueryCommandBaseCodec!(R, ExtendedQueryCommand!(R)) {

	this(ExtendedQueryCommand!(R) cmd) {
		super(cmd);
		if (cmd.fetch() > 0 && statement.isCursorOpen) {
			// restore the state we need for decoding fetch response
			columnDefinitions = statement.rowDesc.columnDefinitions();
		}
	}

	override
	void encode(MySQLEncoder encoder) {
		super.encode(encoder);

		if (statement.isCursorOpen) {
			decoder = new RowResultDecoder!(R)(false, statement.rowDesc);
			sendStatementFetchCommand(statement.statementId, cmd.fetch());
		} else {
			if (cmd.fetch() > 0) {
				//TODO Cursor_type is READ_ONLY?
				sendStatementExecuteCommand(statement.statementId, statement.paramDesc.paramDefinitions(), 
					sendType, cmd.params(), cast(byte) 0x01);
			} else {
				// CURSOR_TYPE_NO_CURSOR
				sendStatementExecuteCommand(statement.statementId, statement.paramDesc.paramDefinitions(), 
					sendType, cmd.params(), cast(byte) 0x00);
			}
		}
	}

	override
	void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
		if (statement.isCursorOpen) {
			int first = payload.getUnsignedByte(payload.readerIndex());
			if (first == Packets.ERROR_PACKET_HEADER) {
				handleErrorPacketPayload(payload);
			} else {
				// decoding COM_STMT_FETCH response
				handleRows(payload, payloadLength, &handleSingleRow);
			}
		} else {
			// decoding COM_STMT_EXECUTE response
			if (cmd.fetch() > 0) {
				switch (commandHandlerState) {
					case CommandHandlerState.INIT:
						int first = payload.getUnsignedByte(payload.readerIndex());
						if (first == Packets.ERROR_PACKET_HEADER) {
							handleErrorPacketPayload(payload);
						} else {
							handleResultsetColumnCountPacketBody(payload);
						}
						break;
					case CommandHandlerState.HANDLING_COLUMN_DEFINITION:
						handleResultsetColumnDefinitions(payload);
						break;
					case CommandHandlerState.COLUMN_DEFINITIONS_DECODING_COMPLETED:
						// accept an EOF_Packet when DEPRECATE_EOF is not enabled
						skipEofPacketIfNeeded(payload);
						goto case;

					case CommandHandlerState.HANDLING_ROW_DATA_OR_END_PACKET:
						handleResultsetColumnDefinitionsDecodingCompleted();
						// need to reset packet number so that we can send a fetch request
						this.sequenceId = 0;
						// send fetch after cursor opened
						decoder = new RowResultDecoder!(R)(false, statement.rowDesc);

						statement.isCursorOpen = true;

						sendStatementFetchCommand(statement.statementId, cmd.fetch());
						break;
					default:
						throw new IllegalStateException("Unexpected state for decoding COM_STMT_EXECUTE response with cursor opening");
				}
			} else {
				super.decodePayload(payload, payloadLength, sequenceId);
			}
		}
	}

	private void sendStatementFetchCommand(long statementId, int count) {
		ByteBuf packet = allocateBuffer();
		// encode packet header
		int packetStartIdx = packet.writerIndex();
		packet.writeMediumLE(0); // will set payload length later by calculation
		packet.writeByte(sequenceId);

		// encode packet payload
		packet.writeByte(CommandType.COM_STMT_FETCH);
		packet.writeIntLE(cast(int) statementId);
		packet.writeIntLE(count);

		// set payload length
		int lenOfPayload = packet.writerIndex() - packetStartIdx - 4;
		packet.setMediumLE(packetStartIdx, lenOfPayload);

		encoder.writeAndFlush(packet);
	}
}
