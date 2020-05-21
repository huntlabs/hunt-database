/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except inBuffer compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to inBuffer writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.driver.postgresql.impl.codec.PgDecoder;

import hunt.database.driver.postgresql.impl.codec.Bind;
import hunt.database.driver.postgresql.impl.codec.DataFormat;
import hunt.database.driver.postgresql.impl.codec.DataType;
import hunt.database.driver.postgresql.impl.codec.DataTypeDesc;
import hunt.database.driver.postgresql.impl.codec.Describe;
import hunt.database.driver.postgresql.impl.codec.ErrorResponse;
import hunt.database.driver.postgresql.impl.codec.InitCommandCodec;
import hunt.database.driver.postgresql.impl.codec.NoticeResponse;
import hunt.database.driver.postgresql.impl.codec.PgColumnDesc;
import hunt.database.driver.postgresql.impl.codec.CommandCodec;
import hunt.database.driver.postgresql.impl.codec.PgParamDesc;
import hunt.database.driver.postgresql.impl.codec.PgProtocolConstants;
import hunt.database.driver.postgresql.impl.codec.PgRowDesc;
import hunt.database.driver.postgresql.impl.codec.Parse;
import hunt.database.driver.postgresql.impl.codec.PasswordMessage;
import hunt.database.driver.postgresql.impl.codec.QueryCommandBaseCodec;
import hunt.database.driver.postgresql.impl.codec.Response;
import hunt.database.driver.postgresql.impl.codec.StartupMessage;
import hunt.database.base.Util;

import hunt.database.base.impl.Notification;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.TxStatus;

import hunt.io.ByteBuffer;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.codec.Decoder;
import hunt.net.Connection;
import hunt.net.buffer;

import std.container.dlist;
import std.conv;


/**
 *
 * Decoder for <a href="https://www.postgresql.org/docs/9.5/static/protocol.html">PostgreSQL protocol</a>
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */

class PgDecoder : Decoder {

    private ByteBufAllocator alloc;
    private DList!(CommandCodecBase) *inflight;
    private ByteBuf inBuffer;
    private CommandCompleteProcessor processor;

    this(ref DList!(CommandCodecBase) inflight) {
        this.inflight = &inflight;
        processor = new CommandCompleteProcessor();
        alloc = UnpooledByteBufAllocator.DEFAULT();
    }

    // override
    // void handlerAdded(ChannelHandlerContext ctx) {
    //     alloc = ctx.alloc();
    // }

    void decode(ByteBuffer payload, Connection connection) {
        try {
            doEecode(payload, connection);
        } catch(Exception ex) {
            version(HUNT_DEBUG) warning(ex);
            else warning(ex.msg);
        }
    }

    private void doEecode(ByteBuffer msg, Connection connection) {
        // version(HUNT_DB_DEBUG_MORE) tracef("decoding buffer: %s", msg.toString());

        ByteBuf buff = Unpooled.wrappedBuffer(msg);
        if (inBuffer is null) {
            inBuffer = buff;
        } else {
            CompositeByteBuf composite = cast(CompositeByteBuf) inBuffer;
            if (composite is null) {
                composite = alloc.compositeBuffer();
                composite.addComponent(true, inBuffer);
                inBuffer = composite;
            }
            composite.addComponent(true, buff);
        }

        while (true) {
            int available = inBuffer.readableBytes();
            if (available < 5) {
                break;
            }
            int beginIdx = inBuffer.readerIndex();
            int length = inBuffer.getInt(beginIdx + 1);
            if (length + 1 > available) {
                break;
            }
            byte id = inBuffer.getByte(beginIdx);
            int endIdx = beginIdx + length + 1;
            int writerIndex = inBuffer.writerIndex();
            try {
                inBuffer.setIndex(beginIdx + 5, endIdx);
                // version(HUNT_DB_DEBUG_MORE) infof("Protocol(Message type) id=%c", cast(char)id);
                switch (id) {
                    case PgProtocolConstants.MESSAGE_TYPE_READY_FOR_QUERY: {
                        decodeReadyForQuery(inBuffer);
                        break;
                    }
                    case PgProtocolConstants.MESSAGE_TYPE_DATA_ROW: {
                        decodeDataRow(inBuffer);
                        break;
                    }
                    case PgProtocolConstants.MESSAGE_TYPE_COMMAND_COMPLETE: {
                        decodeCommandComplete(inBuffer);
                        break;
                    }
                    case PgProtocolConstants.MESSAGE_TYPE_BIND_COMPLETE: {
                        decodeBindComplete();
                        break;
                    }
                    default: {
                        decodeMessage(id, inBuffer);
                    }
                }
            } catch(Throwable ex) {
                version(HUNT_DEBUG) {
                    warning(ex);
                } else {
                    warning(ex.msg);
                }
            } finally {
                inBuffer.setIndex(endIdx, writerIndex);
            }
        }

        if (inBuffer !is null) {
            if(inBuffer.isReadable()) {
                // copy the remainings in current buffer
                version(HUNT_DB_DEBUG_MORE) infof("copying the remaings: %s", inBuffer.toString());
                inBuffer = inBuffer.copy();
            } else {
                // clear up the buffer
                inBuffer.release();
                inBuffer = null;
            }
        }
    }

    private void decodeMessage(byte id, ByteBuf inBuffer) {
        switch (id) {
            case PgProtocolConstants.MESSAGE_TYPE_ROW_DESCRIPTION: {
                decodeRowDescription(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_ERROR_RESPONSE: {
                decodeError(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_NOTICE_RESPONSE: {
                decodeNotice(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_AUTHENTICATION: {
                decodeAuthentication(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_EMPTY_QUERY_RESPONSE: {
                decodeEmptyQueryResponse();
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_PARSE_COMPLETE: {
                decodeParseComplete();
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_CLOSE_COMPLETE: {
                decodeCloseComplete();
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_NO_DATA: {
                decodeNoData();
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_PORTAL_SUSPENDED: {
                decodePortalSuspended();
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_PARAMETER_DESCRIPTION: {
                decodeParameterDescription(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_PARAMETER_STATUS: {
                decodeParameterStatus(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_BACKEND_KEY_DATA: {
                decodeBackendKeyData(inBuffer);
                break;
            }
            case PgProtocolConstants.MESSAGE_TYPE_NOTIFICATION_RESPONSE: {
                decodeNotificationResponse(inBuffer);
                break;
            }
            default: {
                throw new UnsupportedOperationException();
            }
        }
    }

    private void decodePortalSuspended() {
        inflight.front().handlePortalSuspended();
    }

    private void decodeCommandComplete(ByteBuf inBuffer) {
        int updated = processor.parse(inBuffer);
        inflight.front().handleCommandComplete(updated);
    }

    private void decodeDataRow(ByteBuf inBuffer) {
        CommandCodecBase codec = inflight.front();
        version(HUNT_DB_DEBUG_MORE) tracef("decoding data row: %s", typeid(codec));
        int len = inBuffer.readUnsignedShort();
        codec.decodeRow(len, inBuffer);
    }

    private void  decodeRowDescription(ByteBuf inBuffer) {
        PgColumnDesc[] columns = new PgColumnDesc[inBuffer.readUnsignedShort()];
        for (size_t c = 0; c < columns.length; ++c) {
            string fieldName = Util.readCStringUTF8(inBuffer);
            int tableOID = inBuffer.readInt();
            short columnAttributeNumber = inBuffer.readShort();
            int typeOID = inBuffer.readInt();
            short typeSize = inBuffer.readShort();
            int typeModifier = inBuffer.readInt();
            int textOrBinary = inBuffer.readUnsignedShort(); // Useless for now
            PgColumnDesc column = new PgColumnDesc(
                fieldName,
                tableOID,
                columnAttributeNumber,
                DataTypes.valueOf(typeOID),
                typeSize,
                typeModifier,
                cast(DataFormat)(textOrBinary)
            );
            columns[c] = column;
        }
        PgRowDesc rowDesc = new PgRowDesc(columns);
        inflight.front().handleRowDescription(rowDesc);
    }

    private enum byte I = 'I';
    private enum byte T = 'T';

    private void decodeReadyForQuery(ByteBuf inBuffer) {
        byte id = inBuffer.readByte();
        TxStatus txStatus;
        if (id == I) {
            txStatus = TxStatus.IDLE;
        } else if (id == T) {
            txStatus = TxStatus.ACTIVE;
        } else {
            txStatus = TxStatus.FAILED;
        }
        inflight.front().handleReadyForQuery(txStatus);
    }

    private void decodeError(ByteBuf inBuffer) {
        ErrorResponse response = new ErrorResponse();
        decodeErrorOrNotice(response, inBuffer);
        inflight.front().handleErrorResponse(response);
    }

    private void decodeNotice(ByteBuf inBuffer) {
        NoticeResponse response = new NoticeResponse();
        decodeErrorOrNotice(response, inBuffer);
        inflight.front().handleNoticeResponse(response);
    }

    private void decodeErrorOrNotice(Response response, ByteBuf inBuffer) {
        byte type;
        while ((type = inBuffer.readByte()) != 0) {
            switch (type) {

                case PgProtocolConstants.ERROR_OR_NOTICE_SEVERITY:
                    response.setSeverity(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_CODE:
                    response.setCode(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_MESSAGE:
                    response.setMessage(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_DETAIL:
                    response.setDetail(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_HINT:
                    response.setHint(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_INTERNAL_POSITION:
                    response.setInternalPosition(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_INTERNAL_QUERY:
                    response.setInternalQuery(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_POSITION:
                    response.setPosition(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_WHERE:
                    response.setWhere(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_FILE:
                    response.setFile(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_LINE:
                    response.setLine(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_ROUTINE:
                    response.setRoutine(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_SCHEMA:
                    response.setSchema(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_TABLE:
                    response.setTable(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_COLUMN:
                    response.setColumn(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_DATA_TYPE:
                    response.setDataType(Util.readCStringUTF8(inBuffer));
                    break;

                case PgProtocolConstants.ERROR_OR_NOTICE_CONSTRAINT:
                    response.setConstraint(Util.readCStringUTF8(inBuffer));
                    break;

                default:
                    Util.readCStringUTF8(inBuffer);
                    break;
            }
        }
    }

    private void decodeAuthentication(ByteBuf inBuffer) {

        if(inflight.empty()) {
            warning("inflight is empty");
            return;
        }

        int type = inBuffer.readInt();
        version(HUNT_DB_DEBUG_MORE) tracef("type=%d", type);

        CommandCodecBase cmdCodec = inflight.front();

        switch (type) {
            case PgProtocolConstants.AUTHENTICATION_TYPE_OK: {
                cmdCodec.handleAuthenticationOk();
            }
            break;
            case PgProtocolConstants.AUTHENTICATION_TYPE_MD5_PASSWORD: {
                byte[] salt = new byte[4];
                inBuffer.readBytes(salt);
                cmdCodec.handleAuthenticationMD5Password(salt);
            }
            break;
            case PgProtocolConstants.AUTHENTICATION_TYPE_CLEARTEXT_PASSWORD: {
                cmdCodec.handleAuthenticationClearTextPassword();
            }
            break;
            case PgProtocolConstants.AUTHENTICATION_TYPE_KERBEROS_V5:
            case PgProtocolConstants.AUTHENTICATION_TYPE_SCM_CREDENTIAL:
            case PgProtocolConstants.AUTHENTICATION_TYPE_GSS:
            case PgProtocolConstants.AUTHENTICATION_TYPE_GSS_CONTINUE:
            case PgProtocolConstants.AUTHENTICATION_TYPE_SSPI:
            default:
                throw new UnsupportedOperationException("Authentication type " ~ 
                    type.to!string() ~ " is not supported inBuffer the client");
        }
    }

    private void decodeParseComplete() {
        inflight.front().handleParseComplete();
    }

    private void decodeBindComplete() {
        inflight.front().handleBindComplete();
    }

    private void decodeCloseComplete() {
        inflight.front().handleCloseComplete();
    }

    private void decodeNoData() {
        inflight.front().handleNoData();
    }

    private void decodeParameterDescription(ByteBuf inBuffer) {
        DataTypeDesc[] paramDataTypes = new DataTypeDesc[inBuffer.readUnsignedShort()];
        for (int c = 0; c < paramDataTypes.length; ++c) {
            paramDataTypes[c] = DataTypes.valueOf(inBuffer.readInt());
        }
        inflight.front().handleParameterDescription(new PgParamDesc(paramDataTypes));
    }

    private void decodeParameterStatus(ByteBuf inBuffer) {
        string key = Util.readCStringUTF8(inBuffer);
        string value = Util.readCStringUTF8(inBuffer);
        inflight.front().handleParameterStatus(key, value);
    }

    private void decodeEmptyQueryResponse() {
        inflight.front().handleEmptyQueryResponse();
    }

    private void decodeBackendKeyData(ByteBuf inBuffer) {
        int processId = inBuffer.readInt();
        int secretKey = inBuffer.readInt();
        inflight.front().handleBackendKeyData(processId, secretKey);
    }

    private void decodeNotificationResponse(ByteBuf inBuffer) { // ChannelHandlerContext ctx, 
        implementationMissing(false);
        // ctx.fireChannelRead(new Notification(inBuffer.readInt(), Util.readCStringUTF8(inBuffer), Util.readCStringUTF8(inBuffer)));
    }
}



static class CommandCompleteProcessor : ByteProcessor {
    private enum byte SPACE = 32;
    private int rows;
    bool afterSpace;

    int parse(ByteBuf inBuffer) {
        afterSpace = false;
        rows = 0;
        inBuffer.forEachByte(inBuffer.readerIndex(), inBuffer.readableBytes() - 1, this);
        return rows;
    }

    override
    bool process(byte value) {
        bool space = value == SPACE;
        if (afterSpace) {
            if (space) {
                rows = 0;
            } else {
                rows = rows * 10 + (value - '0');
            }
        } else {
            afterSpace = space;
        }
        return true;
    }
}
