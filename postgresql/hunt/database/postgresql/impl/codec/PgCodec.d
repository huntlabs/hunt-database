/*
 * Copyright (C) 2018 Julien Viet
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
module hunt.database.postgresql.impl.codec.PgCodec;

import hunt.database.postgresql.impl.codec.PgCommandCodec;
import hunt.database.postgresql.impl.codec.PgDecoder;
import hunt.database.postgresql.impl.codec.PgEncoder;

// import io.netty.channel.ChannelHandlerContext;
// import io.netty.channel.CombinedChannelDuplexHandler;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandResponse;
// import io.vertx.core.VertxException;

// import java.util.ArrayDeque;
// import java.util.Iterator;

import hunt.net.codec.Codec;

import std.container.dlist;

/**
*/
class PgCodec : Codec { // CombinedChannelDuplexHandler!(PgDecoder, PgEncoder)

    // private ArrayDeque<PgCommandCodec<?, ?>> inflight = new ArrayDeque<>();
    private DList!(PgCommandCodecBase) inflight;
    private PgDecoder decoder;
    private PgEncoder encoder;

    this() {
        decoder = new PgDecoder(inflight);
        encoder = new PgEncoder(decoder, inflight);
        init(decoder, encoder);
    }


    Encoder getEncoder() {
        return encoder;
    }

    Decoder getDecoder() {
        return decoder;
    }

    // override
    // void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
    //     fail(ctx, cause);
    //     super.exceptionCaught(ctx, cause);
    // }

    // private void fail(ChannelHandlerContext ctx, Throwable cause) {
    //     for  (Iterator<PgCommandCodec<?, ?>> it = inflight.iterator(); it.hasNext();) {
    //         PgCommandCodec<?, ?> codec = it.next();
    //         it.remove();
    //         CommandResponse!(Object) failure = CommandResponse.failure(cause);
    //         failure.cmd = (CommandBase) codec.cmd;
    //         ctx.fireChannelRead(failure);
    //     }
    // }

    // override
    // void channelInactive(ChannelHandlerContext ctx) {
    //     fail(ctx, new VertxException("closed"));
    //     super.channelInactive(ctx);
    // }
}
