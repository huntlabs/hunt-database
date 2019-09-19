module hunt.database.driver.mysql.impl.codec.MySQLEncoder;

import hunt.database.driver.mysql.impl.codec.CapabilitiesFlag;
import hunt.database.driver.mysql.impl.codec.CloseConnectionCommandCodec;
import hunt.database.driver.mysql.impl.codec.CloseStatementCommandCodec;
import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.ExtendedBatchQueryCommandCodec;
import hunt.database.driver.mysql.impl.codec.ExtendedQueryCommandCodec;
import hunt.database.driver.mysql.impl.codec.InitCommandCodec;
import hunt.database.driver.mysql.impl.codec.PrepareStatementCodec;
import hunt.database.driver.mysql.impl.codec.ResetStatementCommandCodec;
import hunt.database.driver.mysql.impl.codec.SimpleQueryCommandCodec;

import hunt.database.driver.mysql.impl.command.ChangeUserCommand;
import hunt.database.driver.mysql.impl.command.DebugCommand;
import hunt.database.driver.mysql.impl.command.InitDbCommand;
import hunt.database.driver.mysql.impl.command.PingCommand;
import hunt.database.driver.mysql.impl.command.ResetConnectionCommand;
import hunt.database.driver.mysql.impl.command.SetOptionCommand;
import hunt.database.driver.mysql.impl.command.StatisticsCommand;

import hunt.database.base.AsyncResult;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.ParamDesc;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command;
import hunt.database.base.RowSet;

import hunt.collection.ArrayDeque;
import hunt.collection.ByteBuffer;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer;
import hunt.net.codec.Encoder;
import hunt.net.Connection;
import hunt.text.Charset;

import std.container.dlist;
import std.range;
import std.variant;

/**
 * 
 */
class MySQLEncoder : EncoderChain {

    // private final ArrayDeque<CommandCodec<?, ?>> inflight;
    private DList!(CommandCodecBase) *inflight;
    Connection ctx;

    int clientCapabilitiesFlag = 0x00000000;
    Charset charset;

    this(ref DList!(CommandCodecBase) inflight) {
        this.inflight = &inflight;
        this.charset = StandardCharsets.UTF_8;
        initSupportedCapabilitiesFlags();
    }

    // override
    // void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) {
    //     if (msg instanceof CommandBase<?>) {
    //         CommandBase<?> cmd = (CommandBase<?>) msg;
    //         write(cmd);
    //     } else {
    //         super.write(ctx, msg, promise);
    //     }
    // }

    override void encode(Object message, Connection connection) {
        ctx = connection;

        ICommand cmd = cast(ICommand)message;
        if(cmd is null) {
            warningf("The message is not a ICommand: %s", typeid(message));
        }

        version(HUNT_DB_DEBUG) 
        tracef("encoding a message: %s", typeid(message));

        CommandCodecBase cmdCodec = wrap(cmd);

        cmdCodec.completionHandler = (ICommandResponse resp) {
            version(HUNT_DB_DEBUG) {
                infof("message encoding completed");
                // CommandCodecBase c = inflight.front();
                // assert(cmdCodec is c);
                if(resp.failed()) {
                    Throwable th = resp.cause();
                    warningf("Response error: %s", th.msg);
                }
            }
            version(HUNT_DB_DEBUG) tracef("%s", typeid(cast(Object)resp));
            inflight.removeFront();

            if(!resp.isCommandAttatched()) {
                // infof("No command attatched for %s", typeid(cast(Object)cmdCodec));
                resp.attachCommand(cmdCodec.getCommand());
            }

            ConnectionEventHandler handler = ctx.getHandler();
            handler.messageReceived(ctx, cast(Object)resp);
        };

        inflight.insertBack(cmdCodec);
        cmdCodec.encode(this);
        // flush();
	}

    private CommandCodecBase wrap(ICommand cmd) {
        InitCommand initCommand = cast(InitCommand) cmd;
        if (initCommand !is null) {
            return new InitCommandCodec(initCommand);
        }

        SimpleQueryCommand!(RowSet) simpleCommand = cast(SimpleQueryCommand!(RowSet))cmd;
        if(simpleCommand !is null) {
            return new SimpleQueryCommandCodec!RowSet(simpleCommand);
        }

        PrepareStatementCommand prepareCommand = cast(PrepareStatementCommand)cmd;
        if(prepareCommand !is null) {
            return new PrepareStatementCodec(prepareCommand);
        }

        ExtendedQueryCommand!RowSet extendedCommand = cast(ExtendedQueryCommand!RowSet)cmd;
        if(extendedCommand !is null) {
            return new ExtendedQueryCommandCodec!RowSet(extendedCommand);
        }

        ExtendedBatchQueryCommand!RowSet batchQueryCommand = cast(ExtendedBatchQueryCommand!RowSet)cmd;
        if(batchQueryCommand !is null) {
            return new ExtendedBatchQueryCommandCodec!RowSet(batchQueryCommand);
        }

        CloseConnectionCommand connCommand = cast(CloseConnectionCommand)cmd;
        if(connCommand !is null) {
            return new CloseConnectionCommandCodec(connCommand);
        }

        CloseCursorCommand cursorCommand = cast(CloseCursorCommand)cmd;
        if(cursorCommand !is null) {
            return new ResetStatementCommandCodec(cursorCommand);
        }

        CloseStatementCommand statementCommand = cast(CloseStatementCommand)cmd;
        if(statementCommand !is null) {
            return new CloseStatementCommandCodec(statementCommand);
        }
        warning("Unsupported command " ~ (cast(Object)cmd).toString());
        throw new UnsupportedOperationException("Todo");
    }

    // private CommandCodec<?, ?> wrap(CommandBase<?> cmd) {
    //     if (cmd instanceof InitCommand) {
    //         return new InitCommandCodec((InitCommand) cmd);
    //     } else if (cmd instanceof SimpleQueryCommand) {
    //         return new SimpleQueryCommandCodec((SimpleQueryCommand) cmd);
    //     } else if (cmd instanceof ExtendedQueryCommand) {
    //         return new ExtendedQueryCommandCodec((ExtendedQueryCommand) cmd);
    //     } else if (cmd instanceof ExtendedBatchQueryCommand<?>) {
    //         return new ExtendedBatchQueryCommandCodec<>((ExtendedBatchQueryCommand<?>) cmd);
    //     } else if (cmd instanceof CloseConnectionCommand) {
    //         return new CloseConnectionCommandCodec((CloseConnectionCommand) cmd);
    //     } else if (cmd instanceof PrepareStatementCommand) {
    //         return new PrepareStatementCodec((PrepareStatementCommand) cmd);
    //     } else if (cmd instanceof CloseStatementCommand) {
    //         return new CloseStatementCommandCodec((CloseStatementCommand) cmd);
    //     } else if (cmd instanceof CloseCursorCommand) {
    //         return new ResetStatementCommandCodec((CloseCursorCommand) cmd);
    //     } else if (cmd instanceof PingCommand) {
    //         return new PingCommandCodec((PingCommand) cmd);
    //     } else if (cmd instanceof InitDbCommand) {
    //         return new InitDbCommandCodec((InitDbCommand) cmd);
    //     } else if (cmd instanceof StatisticsCommand) {
    //         return new StatisticsCommandCodec((StatisticsCommand) cmd);
    //     } else if (cmd instanceof SetOptionCommand) {
    //         return new SetOptionCommandCodec((SetOptionCommand) cmd);
    //     } else if (cmd instanceof ResetConnectionCommand) {
    //         return new ResetConnectionCommandCodec((ResetConnectionCommand) cmd);
    //     } else if (cmd instanceof DebugCommand) {
    //         return new DebugCommandCodec((DebugCommand) cmd);
    //     } else if (cmd instanceof ChangeUserCommand) {
    //         return new ChangeUserCommandCodec((ChangeUserCommand) cmd);
    //     } else {
    //         System.out.println("Unsupported command " ~ cmd);
    //         throw new UnsupportedOperationException("Todo");
    //     }
    // }


    void write(ByteBuf outBuffer) {
        // FIXME: Needing refactor or cleanup -@zxp at 9/3/2019, 6:19:07 PM
        // 
        writeAndFlush(outBuffer);
    }

    void writeAndFlush(ByteBuf outBuffer) {
        version(HUNT_DB_DEBUG) trace("writting ...");

        if(ctx is null) {
            warning("ctx is null");
            return ;
        }

        if (outBuffer !is null) {
            ByteBuf buff = outBuffer;
            byte[] avaliableData = buff.getReadableBytes();
            version(HUNT_DB_DEBUG_MORE) {
                tracef("buffer: %s", buff.toString());
                tracef("buffer data: %s", cast(string)avaliableData);
            }
            ctx.write(cast(const(ubyte)[])avaliableData);
        }        
    }
    

    private void initSupportedCapabilitiesFlags() {
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_PLUGIN_AUTH;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_SECURE_CONNECTION;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_PROTOCOL_41;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_TRANSACTIONS;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_MULTI_STATEMENTS;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_MULTI_RESULTS;
        clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_SESSION_TRACK;
    }
}
