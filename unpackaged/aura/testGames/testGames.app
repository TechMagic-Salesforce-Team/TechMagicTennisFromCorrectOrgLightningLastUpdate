<aura:application access="global" implements="ltng:allowGuestAccess" extends="force:slds">

    <style>
        #snackbar {
            visibility: hidden;
            min-width: 250px;
            margin-left: -125px;
            background-color: #333;
            color: #fff;
            text-align: center;
            border-radius: 2px;
            padding: 16px;
            position: fixed;
            z-index: 1;
            left: 50%;
            bottom: 30px;
            font-size: 17px;
        }

        #snackbar.show {
            visibility: visible;
            -webkit-animation: fadein 0.5s, fadeout 0.5s 2.5s;
            animation: fadein 0.5s, fadeout 0.5s 2.5s;
        }

        @-webkit-keyframes fadein {
            from {bottom: 0; opacity: 0;}
            to {bottom: 30px; opacity: 1;}
        }

        @keyframes fadein {
            from {bottom: 0; opacity: 0;}
            to {bottom: 30px; opacity: 1;}
        }

        @-webkit-keyframes fadeout {
            from {bottom: 30px; opacity: 1;}
            to {bottom: 0; opacity: 0;}
        }

        @keyframes fadeout {
            from {bottom: 30px; opacity: 1;}
            to {bottom: 0; opacity: 0;}
        }
    </style>



    <!--<div id="snackbar">Some text some message..</div>-->


    <div role="dialog" tabindex="-1" aria-labelledby="header99" class="slds-modal slds-fade-in-open">
        <button class="slds-button slds-button--neutral" onclick="{!c.myAction}">Show snackbar</button>
        <div class="slds-modal__container" id="mydiv">

            <div id="snackbar">Some text some message..</div>
            <div class="slds-modal__content slds-p-around--large">
                <fieldset style="width: 100%; margin: 10px auto">
                    <form class="slds-form--compound">
                        <div class="slds-grid slds-wrap">
                            <div class="slds-form-element slds-col slds-small-size--2-of-12 slds-size--3-of-12 slds-medium-size--3-of-12 slds-large-size--3-of-12" style="border: 1px solid white;">
                                <p class="slds-text-body--small slds-align--absolute-center">Vova Babin</p>
                            </div>

                            <div class="slds-form-element slds-col slds-small-size--2-of-12 slds-size--3-of-12 slds-medium-size--2-of-12 slds-large-size--2-of-12" style="border: 1px solid white;">
                                <div class="slds-form-element slds-col slds-small-size--1-of-12 slds-size--1-of-3 slds-medium-size--1-of-3 slds-large-size--1-of-3" style="border: 1px solid white; float: left;">
                                </div>
                                <div class="slds-form-element__control slds-col slds-small-size--2-of-3 slds-size--2-of-3 slds-medium-size--2-of-3 slds-large-size--2-of-3" style="float: left;">
                                    <ui:inputText class="slds-input"/>
                                </div>
                            </div>

                            <div class="slds-form-element slds-col slds-small-size--3-of-12 slds-size--1-of-12 slds-medium-size--1-of-12 slds-large-size--1-of-12" style="border: 1px solid white;">
                                <p class="slds-align--absolute-center">:</p>
                            </div>



                            <div class="slds-form-element slds-col slds-small-size--2-of-12 slds-size--3-of-12 slds-medium-size--2-of-12 slds-large-size--2-of-12" style="border: 1px solid white;">
                                <div class="slds-form-element__control slds-col slds-size--2-of-3 slds-small-size--2-of-3 slds-medium-size--12-of-3 slds-large-size--2-of-3"
                                     style="float: left;">
                                    <ui:inputText class="slds-input"/>
                                </div>
                            </div>

                            <div class="slds-form-element slds-col slds-size--3-of-12 slds-medium-size--3-of-12 slds-large-size--3-of-12" style="border: 1px solid white;">
                                <p class="slds-text-body--small slds-align--absolute-center">Rostyslav Haydukevych</p>
                            </div>


                        </div>
                    </form>
                </fieldset>
            </div>
        </div>
    </div>



</aura:application>