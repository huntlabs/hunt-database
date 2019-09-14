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
module hunt.database.driver.mysql.impl.codec.InitCommandCodec;

import hunt.database.driver.mysql.impl.codec.CapabilitiesFlag;
import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.InitialHandshakePacket;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;
import hunt.database.driver.mysql.impl.codec.Packets;

import hunt.database.driver.mysql.impl.MySQLCollation;
import hunt.database.driver.mysql.impl.util.BufferUtils;
import hunt.database.driver.mysql.impl.util.Native41Authenticator;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.InitCommand;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.collection.Map;
import hunt.text.Charset;

import std.algorithm;
import std.array;
import std.conv;
import std.string;

/**
 * 
 */
class InitCommandCodec : CommandCodec!(DbConnection, InitCommand) {

    private enum int SCRAMBLE_LENGTH = 20;
    private enum int AUTH_PLUGIN_DATA_PART1_LENGTH = 8;

    private enum int ST_CONNECTING = 0;
    private enum int ST_AUTHENTICATING = 1;
    private enum int ST_CONNECTED = 2;

    private int status = 0;

    this(InitCommand cmd) {
        super(cmd);
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        switch (status) {
            case ST_CONNECTING:
                decodeInit0(encoder, cmd, payload);
                status = ST_AUTHENTICATING;
                break;
            case ST_AUTHENTICATING:
                decodeInit1(cmd, payload);
                break;

            default:
                warningf("Can't handle status: %d", status);
                break;
        }
    }

    private void decodeInit0(MySQLEncoder encoder, InitCommand cmd, ByteBuf payload) {
        short protocolVersion = payload.readUnsignedByte();

        string serverVersion = BufferUtils.readNullTerminatedString(payload, StandardCharsets.US_ASCII);
        version(HUNT_DEBUG) {
            infof("protocolVersion: %d, serverVersion: %s", protocolVersion, serverVersion);
        }

        // we assume the server version follows ${major}.${minor}.${release} in https://dev.mysql.com/doc/refman/8.0/en/which-version.html
        string[] versionNumbers = serverVersion.split(".");
        int majorVersion = to!int(versionNumbers[0]);
        int minorVersion = to!int(versionNumbers[1]);
        // we should truncate the possible suffixes here
        string releaseVersion = versionNumbers[2];
        int releaseNumber;
        int indexOfFirstSeparator = cast(int)releaseVersion.indexOf("-");
        if (indexOfFirstSeparator != -1) {
            // handle unstable release suffixes
            string releaseNumberString = releaseVersion[0 .. indexOfFirstSeparator];
            releaseNumber = to!int(releaseNumberString);
        } else {
            releaseNumber = to!int(versionNumbers[2]);
        }
        if (majorVersion == 5 && (minorVersion < 7 || (minorVersion == 7 && releaseNumber < 5))) {
            // EOF_HEADER is enabled
        } else {
            encoder.clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_DEPRECATE_EOF;
        }

        long connectionId = payload.readUnsignedIntLE();

        // read first part of scramble
        byte[] scramble = new byte[SCRAMBLE_LENGTH];
        payload.readBytes(scramble, 0, AUTH_PLUGIN_DATA_PART1_LENGTH);

        //filler
        payload.readByte();

        // read lower 2 bytes of Capabilities flags
        int serverCapabilitiesFlags = payload.readUnsignedShortLE();

        short characterSet = payload.readUnsignedByte();

        int statusFlags = payload.readUnsignedShortLE();

        // read upper 2 bytes of Capabilities flags
        int capabilityFlagsUpper = payload.readUnsignedShortLE();
        serverCapabilitiesFlags |= (capabilityFlagsUpper << 16);

        // length of the combined auth_plugin_data (scramble)
        short lenOfAuthPluginData;
        bool isClientPluginAuthSupported = (serverCapabilitiesFlags & CapabilitiesFlag.CLIENT_PLUGIN_AUTH) != 0;
        if (isClientPluginAuthSupported) {
            lenOfAuthPluginData = payload.readUnsignedByte();
        } else {
            payload.readerIndex(payload.readerIndex() + 1);
            lenOfAuthPluginData = 0;
        }

        // 10 bytes reserved
        payload.readerIndex(payload.readerIndex() + 10);

        // Rest of the plugin provided data
        payload.readBytes(scramble, AUTH_PLUGIN_DATA_PART1_LENGTH, 
            max(SCRAMBLE_LENGTH - AUTH_PLUGIN_DATA_PART1_LENGTH, lenOfAuthPluginData - 9));
        payload.readByte(); // reserved byte

        string authPluginName = null;
        if (isClientPluginAuthSupported) {
            authPluginName = BufferUtils.readNullTerminatedString(payload, StandardCharsets.UTF_8);
        }

        //TODO we may not need an extra object here?(inline)
        // InitialHandshakePacket initialHandshakePacket = new InitialHandshakePacket(serverVersion,
        //     connectionId,
        //     serverCapabilitiesFlags,
        //     characterSet,
        //     statusFlags,
        //     scramble,
        //     authPluginName
        // );

        bool ssl = false;
        if (ssl) {
            //TODO ssl
            implementationMissing(false);
        } else {
            if (cmd.database() !is null && !cmd.database().empty()) {
                encoder.clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_CONNECT_WITH_DB;
            }
            string authMethodName = authPluginName; // initialHandshakePacket.getAuthMethodName();
            byte[] serverScramble = scramble; // initialHandshakePacket.getScramble();
            Map!(string, string) properties = cmd.properties();
            MySQLCollation collation = MySQLCollation.utf8_general_ci;
            try {
                if(properties.containsKey("collation")) {
                    collation = MySQLCollation.valueOfName(properties.get("collation"));
                    properties.remove("collation");
                } else {
                    version(HUNT_DEBUG) warning(properties.toString());
                }
            } catch (IllegalArgumentException e) {
                warning(e);
                // if(completionHandler !is null)
                //     completionHandler(failedResponse!(DbConnection)(e));
                // return;
            }
            int collationId = collation.collationId();
            encoder.charset = collation.mappedCharsetName(); // Charset.forName(collation.mappedCharsetName());

            Map!(string, string) clientConnectionAttributes = properties;
            if (clientConnectionAttributes !is null && !clientConnectionAttributes.isEmpty()) {
                encoder.clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_CONNECT_ATTRS;
            }
            encoder.clientCapabilitiesFlag &= serverCapabilitiesFlags; // initialHandshakePacket.getServerCapabilitiesFlags();
            sendHandshakeResponseMessage(cmd.username(), cmd.password(), cmd.database(), 
                    collationId, serverScramble, authMethodName, clientConnectionAttributes);
        }
    }

    private void decodeInit1(InitCommand cmd, ByteBuf payload) {
        //TODO auth switch support
        Packets header = cast(Packets)payload.getUnsignedByte(payload.readerIndex());
        switch (header) {
            case Packets.OK_PACKET_HEADER:
                status = ST_CONNECTED;
                if(completionHandler !is null) {
                    completionHandler(succeededResponse!(DbConnection)(cmd.connection()));
                }
                break;
            case Packets.ERROR_PACKET_HEADER:
                handleErrorPacketPayload(payload);
                break;
            default:
                throw new UnsupportedOperationException();
        }
    }

    private void sendHandshakeResponseMessage(string username, string password, string database, 
            int collationId, byte[] serverScramble, string authMethodName, 
            Map!(string, string) clientConnectionAttributes) {

        ByteBuf packet = allocateBuffer();
        // encode packet header
        int packetStartIdx = packet.writerIndex();
        packet.writeMediumLE(0); // will set payload length later by calculation
        packet.writeByte(sequenceId);

        // encode packet payload
        int clientCapabilitiesFlags = encoder.clientCapabilitiesFlag;
        packet.writeIntLE(clientCapabilitiesFlags);
        packet.writeIntLE(0xFFFFFF);
        packet.writeByte(collationId);
        byte[] filler = new byte[23];
        packet.writeBytes(filler);
        BufferUtils.writeNullTerminatedString(packet, username, StandardCharsets.UTF_8);
        if (password is null || password.empty()) {
            packet.writeByte(0);
        } else {
            //TODO support different auth methods here

            byte[] scrambledPassword = Native41Authenticator.encode(password, StandardCharsets.UTF_8, serverScramble);
            if ((clientCapabilitiesFlags & CapabilitiesFlag.CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA) != 0) {
                BufferUtils.writeLengthEncodedInteger(packet, scrambledPassword.length);
                packet.writeBytes(scrambledPassword);
            } else if ((clientCapabilitiesFlags & CapabilitiesFlag.CLIENT_SECURE_CONNECTION) != 0) {
                packet.writeByte(cast(int)scrambledPassword.length);
                packet.writeBytes(scrambledPassword);
            } else {
                packet.writeByte(0);
            }
        }
        if ((clientCapabilitiesFlags & CapabilitiesFlag.CLIENT_CONNECT_WITH_DB) != 0) {
            BufferUtils.writeNullTerminatedString(packet, database, StandardCharsets.UTF_8);
        }
        if ((clientCapabilitiesFlags & CapabilitiesFlag.CLIENT_PLUGIN_AUTH) != 0) {
            BufferUtils.writeNullTerminatedString(packet, authMethodName, StandardCharsets.UTF_8);
        }
        if ((clientCapabilitiesFlags & CapabilitiesFlag.CLIENT_CONNECT_ATTRS) != 0) {
            ByteBuf kv =  allocateBuffer();
            foreach (string key, string value; clientConnectionAttributes) {
                BufferUtils.writeLengthEncodedString(kv, key, StandardCharsets.UTF_8);
                BufferUtils.writeLengthEncodedString(kv, value, StandardCharsets.UTF_8);
            }
            BufferUtils.writeLengthEncodedInteger(packet, kv.readableBytes());
            packet.writeBytes(kv);
        }

        // set payload length
        int payloadLength = packet.writerIndex() - packetStartIdx - 4;
        packet.setMediumLE(packetStartIdx, payloadLength);

        sendPacket(packet, payloadLength);
    }
}
