//replace this file with your cloud functions index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.welcomeMessage = functions.auth.user().onCreate(async (user)=>{
    console.log(user.displayName);
});

exports.sendNotifications = functions.firestore.document('/messages/{uid}/{id}/{timestamp}').onCreate(
    async (snapshot) => {
        //content
        var content = snapshot.data().content;
        //from
        var fromId = snapshot.data().idFrom;
        //to
        var toId = snapshot.data().idTo;

        //find user with fromId
        admin.firestore().doc('users/'+fromId).get().then((fromDoc)=>{
            //check whether user exits
            if(!fromDoc.exists){
                console.log('no such user!');  
            }else{
                //find user with toId 
                admin.firestore().doc('users/'+toId).get().then((toDoc)=>{
                    //check whether user exits
                    if(!toDoc.exists){
                        console.log('no such user!');
                    }else{
                        //notification data
                        var toToken = toDoc.data().token;
                        var fromIcon = fromDoc.data().photo_uri;
                        var fromName = fromDoc.data().display_name;
                        //structure
                        const payload = {
                            notification: {
                              title: fromName,
                              body: content ? (content.length <= 100 ? content : content.substring(0, 97) + '...') : '',
                              icon: fromIcon || '/media/images/placeholder.png',
                              click_action: "FLUTTER_NOTIFICATION_CLICK",
                            }
                          };
                          
                        //if reciver does not have a friend with this id 
                        admin.firestore().collection('users/'+toId+'/friends/').doc(fromId).get().then((friend)=>{
                            if(!friend.exists){
                                //add this user to friends
                                friend.ref.set({'friend_id':fromId,'time_added':new Date().getTime().toString(),'latest_message':''});
                            }
                        })
                    }
                });
            }
            //error
            console.log('failed');
        });

    });


    exports.latestMessage = functions.firestore.document('/messages/{uid}/{id}/{timestamp}').onCreate(  
        async (snapshot)=>{
            //get required messages
            var idTo = snapshot.data().idTo;
            var idFrom = snapshot.data().idFrom;
            var type = snapshot.data().type;
            //if this is a photo just show 'photo'
            var message = type == 'photo' ? 'photo':snapshot.data().content;
            admin.firestore().collection('users/'+idTo+'/friends/').doc(idFrom).get().then((friend)=>{
                //execute this snippet if there is a user with this id in my friends
                if(friend.exists){
                    //update the latest message at the following path : users/toId/friends/idFrom
                    friend
                    .ref
                    .update({'latest_message':message.length <= 50 ? message : message.substring(0,47)+'...'});
                    //update the latest message at the following path : users/idFrom/friends/idTo
                    admin
                    .firestore()
                    .collection('users/'+idFrom+'/friends/')
                    .doc(idTo)
                    .update({'latest_message':message.length <= 50 ? message : message.substring(0,47)+'...'});
                }
            }
            );
    
        }
    );
