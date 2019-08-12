module hunt.database.mysql.impl.codec;

import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelOutboundHandlerAdapter;
import io.netty.channel.ChannelPromise;
import hunt.database.mysql.impl.command.ChangeUserCommand;
import hunt.database.mysql.impl.command.DebugCommand;
import hunt.database.mysql.impl.command.InitDbCommand;
import hunt.database.mysql.impl.command.PingCommand;
import hunt.database.mysql.impl.command.ResetConnectionCommand;
import hunt.database.mysql.impl.command.SetOptionCommand;
import hunt.database.mysql.impl.command.StatisticsCommand;
import hunt.database.base.impl.command.*;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayDeque;

import static hunt.database.mysql.impl.codec.CapabilitiesFlag.*;

class MySQLEncoder : ChannelOutboundHandlerAdapter {

  private final ArrayDeque<CommandCodec<?, ?>> inflight;
  ChannelHandlerContext chctx;

  int clientCapabilitiesFlag = 0x00000000;
  Charset charset;

  MySQLEncoder(ArrayDeque<CommandCodec<?, ?>> inflight) {
    this.inflight = inflight;
    this.charset = StandardCharsets.UTF_8;
    initSupportedCapabilitiesFlags();
  }

  override
  void handlerAdded(ChannelHandlerContext ctx) {
    chctx = ctx;
  }

  override
  void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) throws Exception {
    if (msg instanceof CommandBase<?>) {
      CommandBase<?> cmd = (CommandBase<?>) msg;
      write(cmd);
    } else {
      super.write(ctx, msg, promise);
    }
  }

  void write(CommandBase<?> cmd) {
    CommandCodec<?, ?> codec = wrap(cmd);
    codec.completionHandler = resp -> {
      CommandCodec c = inflight.poll();
      resp.cmd = (CommandBase) c.cmd;
      chctx.fireChannelRead(resp);
    };
    inflight.add(codec);
    codec.encode(this);
  }

  private CommandCodec<?, ?> wrap(CommandBase<?> cmd) {
    if (cmd instanceof InitCommand) {
      return new InitCommandCodec((InitCommand) cmd);
    } else if (cmd instanceof SimpleQueryCommand) {
      return new SimpleQueryCommandCodec((SimpleQueryCommand) cmd);
    } else if (cmd instanceof ExtendedQueryCommand) {
      return new ExtendedQueryCommandCodec((ExtendedQueryCommand) cmd);
    } else if (cmd instanceof ExtendedBatchQueryCommand<?>) {
      return new ExtendedBatchQueryCommandCodec<>((ExtendedBatchQueryCommand<?>) cmd);
    } else if (cmd instanceof CloseConnectionCommand) {
      return new CloseConnectionCommandCodec((CloseConnectionCommand) cmd);
    } else if (cmd instanceof PrepareStatementCommand) {
      return new PrepareStatementCodec((PrepareStatementCommand) cmd);
    } else if (cmd instanceof CloseStatementCommand) {
      return new CloseStatementCommandCodec((CloseStatementCommand) cmd);
    } else if (cmd instanceof CloseCursorCommand) {
      return new ResetStatementCommandCodec((CloseCursorCommand) cmd);
    } else if (cmd instanceof PingCommand) {
      return new PingCommandCodec((PingCommand) cmd);
    } else if (cmd instanceof InitDbCommand) {
      return new InitDbCommandCodec((InitDbCommand) cmd);
    } else if (cmd instanceof StatisticsCommand) {
      return new StatisticsCommandCodec((StatisticsCommand) cmd);
    } else if (cmd instanceof SetOptionCommand) {
      return new SetOptionCommandCodec((SetOptionCommand) cmd);
    } else if (cmd instanceof ResetConnectionCommand) {
      return new ResetConnectionCommandCodec((ResetConnectionCommand) cmd);
    } else if (cmd instanceof DebugCommand) {
      return new DebugCommandCodec((DebugCommand) cmd);
    } else if (cmd instanceof ChangeUserCommand) {
      return new ChangeUserCommandCodec((ChangeUserCommand) cmd);
    } else {
      System.out.println("Unsupported command " ~ cmd);
      throw new UnsupportedOperationException("Todo");
    }
  }

  private void initSupportedCapabilitiesFlags() {
    clientCapabilitiesFlag |= CLIENT_PLUGIN_AUTH;
    clientCapabilitiesFlag |= CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA;
    clientCapabilitiesFlag |= CLIENT_SECURE_CONNECTION;
    clientCapabilitiesFlag |= CLIENT_PROTOCOL_41;
    clientCapabilitiesFlag |= CLIENT_TRANSACTIONS;
    clientCapabilitiesFlag |= CLIENT_MULTI_STATEMENTS;
    clientCapabilitiesFlag |= CLIENT_MULTI_RESULTS;
    clientCapabilitiesFlag |= CLIENT_SESSION_TRACK;
  }
}
