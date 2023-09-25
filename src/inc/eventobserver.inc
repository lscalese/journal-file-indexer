ROUTINE eventobserver [Type=INC]

#Define Subscribed              ^dc.event.observer.SubscribedD
#Define SubscribedClasses       ^dc.event.observer.ClassesD
#Define TriggerMethod           "Update"
#Define ToCleanMethod           "ToClean"

#Def1arg SubscribeEvent(%args)      ##class(dc.observer.Event).Subscribe(%args)
#Def1arg UnSubscribeEvent(%args)    ##class(dc.observer.Event).UnSubscribe(%args)
#Def1arg SubscribeClass(%args)      ##class(dc.observer.Classes).Subscribe(%args)
#Def1arg UnSubscribeClass(%args)    ##class(dc.observer.Classes).UnSubscribe(%args)