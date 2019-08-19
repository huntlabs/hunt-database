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
module hunt.database.postgresql.pubsub.PostgreSQLSubscriber;

import hunt.database.postgresql.PostgreSQLConnectOptions;
import hunt.database.postgresql.PostgreSQLConnection;
import hunt.database.postgresql.impl.pubsub.PostgreSQLSubscriberImpl;

import hunt.database.base.AsyncResult;

// import java.util.function.Function;

/**
 * A class for managing subscriptions using {@code LISTEN/UNLISTEN} to Postgres channels.
 * <p/>
 * The subscriber manages a single connection to Postgres.
 */
interface PgSubscriber {

    /**
     * Create a subscriber.
     *
     * @param vertx the vertx instance
     * @param options the connect options
     * @return the subscriber
     */
    // static PgSubscriber subscriber(Vertx vertx, PgConnectOptions options) {
    //     return new PgSubscriberImpl(vertx, options);
    // }

    /**
     * Return a channel for the given {@code name}.
     *
     * @param name the channel name
     * <p/>
     * This will be the name of the channel exactly as held by Postgres for sending
     * notifications.  Internally this name will be truncated to the Postgres identifier
     * maxiumum length of {@code (NAMEDATALEN = 64) - 1 == 63} characters, and prepared
     * as a quoted identifier without unicode escape sequence support for use in
     * {@code LISTEN/UNLISTEN} commands.  Examples of channel names and corresponding
     * {@code NOTIFY} commands:
     * <ul>
     *   <li>when {@code name == "the_channel"}: {@code NOTIFY the_channel, 'msg'},
     *   {@code NOTIFY The_Channel, 'msg'}, or {@code NOTIFY "the_channel", 'msg'}
     *   succeed in delivering a message to the created channel
     *   </li>
     *   <li>when {@code name == "The_Channel"}: {@code NOTIFY "The_Channel", 'msg'},
     *   succeeds in delivering a message to the created channel
     *   </li>
     *   <li></li>
     * </ul>
     * @return the channel
     */
    PgChannel channel(string name);

    /**
     * Connect the subscriber to Postgres.
     *
     * @param handler the handler notified of the connection success or failure
     * @return a reference to this, so the API can be used fluently
     */
    PgSubscriber connect(VoidHandler handler);

    /**
     * Set the reconnect policy that is executed when the subscriber is disconnected.
     * <p/>
     * When the subscriber is disconnected, the {@code policy} function is called with the actual
     * number of retries and returns an {@code amountOfTime} value:
     * <ul>
     *   <li>when {@code amountOfTime < 0}: the subscriber is closed and there is no retry</li>
     *   <li>when {@code amountOfTime == 0}: the subscriber retries to connect immediately</li>
     *   <li>when {@code amountOfTime > 0}: the subscriber retries after {@code amountOfTime} milliseconds</li>
     * </ul>
     * <p/>
     * The default policy does not perform any retries.
     *
     * @param policy the policy to set
     * @return a reference to this, so the API can be used fluently
     */
    PgSubscriber reconnectPolicy(Function!(Integer, Long) policy);

    /**
     * Set an handler called when the subscriber is closed.
     *
     * @param handler the handler
     * @return a reference to this, so the API can be used fluently
     */
    PgSubscriber closeHandler(VoidHandler handler);

    /**
     * @return the actual connection to Postgres, it might be {@code null}
     */
    PgConnection actualConnection();

    /**
     * @return whether the subscriber is closed
     */
    boolean closed();

    /**
     * Close the subscriber, the retry policy will not be invoked.
     */
    void close();

}
