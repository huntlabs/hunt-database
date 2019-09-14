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
module hunt.database.driver.postgresql.pubsub.PostgreSQLChannel;

// import io.vertx.codegen.annotations.Fluent;
// import io.vertx.codegen.annotations.VertxGen;
// import io.vertx.core.Handler;
// import io.vertx.core.streams.ReadStream;

/**
 * A channel to Postgres that tracks the subscription to a given Postgres channel using the {@code LISTEN/UNLISTEN} commands.
 * <p/>
 * When paused the channel discards the messages.
 */
// interface PgChannel : ReadStream!(String) {

//     /**
//      * Set an handler called when the the channel get subscribed.
//      *
//      * @param handler the handler
//      * @return a reference to this, so the API can be used fluently
//      */
//     PgChannel subscribeHandler(VoidHandler handler);

//     /**
//      * Set or unset an handler to be called when a the channel is notified by Postgres.
//      * <p/>
//      * <ul>
//      *   <li>when the handler is set, the subscriber sends a {@code LISTEN} command if needed</li>
//      *   <li>when the handler is unset, the subscriber sends a {@code UNLISTEN} command if needed</li>
//      * </ul>
//      *
//      * @param handler the handler
//      * @return a reference to this, so the API can be used fluently
//      */
//     override
//     PgChannel handler(Handler!(String) handler);

//     /**
//      * Pause the channel, all notifications are discarded.
//      *
//      * @return a reference to this, so the API can be used fluently
//      */
//     override
//     PgChannel pause();

//     /**
//      * Resume the channel.
//      *
//      * @return a reference to this, so the API can be used fluently
//      */
//     override
//     PgChannel resume();

//     /**
//      * Set an handler to be called when no more notifications will be received.
//      *
//      * @param endHandler the handler
//      * @return a reference to this, so the API can be used fluently
//      */
//     override
//     PgChannel endHandler(VoidHandler endHandler);

//     override
//     PgChannel exceptionHandler(Handler!(Throwable) handler);

// }
