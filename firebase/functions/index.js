'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendFollowerNotification = functions.database.ref('/chats/{currUser}/{otherUser}/{}')
    .onWrite((change, context) => {
        const currUser = context.params.currUser;
        const otherUser = context.params.otherUser;
        if (!change.after._data['sender']) {
            console.log('After Snap ', change.after);
            console.log('We have a new follower UID:', otherUser, 'for user:', currUser);
            let idVal = admin.database()
                .ref(`/tokens/${currUser}`).once('value').then(id => {
                    console.log('Token is ' + id.val());
                    const payload = {
                        notification: {
                            title: `${change.after._data['name']} sent you a message`,
                            body: `${change.after._data['message']}`,
                        }
                    };
                    admin.messaging().sendToDevice(id.val(), payload).then((response) => {
                        response.results.forEach((result, index) => {
                            const error = result.error;
                            if (error) {
                                console.error('Failure sending notification to', tokens[index], error);
                            }
                        });
                        return response;
                    }).catch((err)=>console.log(err));


                    return id.val();
                }).catch((err) => {
                    console.log('Error is ' + err);
                });
            console.log('After val' + idVal);
        }
    });