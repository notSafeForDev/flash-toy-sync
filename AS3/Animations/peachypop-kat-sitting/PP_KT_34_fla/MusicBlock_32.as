package PP_KT_34_fla
{
    import flash.display.*;
    import flash.events.*;

    dynamic public class MusicBlock_32 extends MovieClip
    {
        public var buttonm:SimpleButton;
        public var buttonum:SimpleButton;

        public function MusicBlock_32()
        {
            addFrameScript(0, this.frame1, 2, this.frame3);
            return;
        }// end function

        public function mb2(event:MouseEvent) : void
        {
            gotoAndPlay(1);
            return;
        }// end function

        public function mb1(event:MouseEvent) : void
        {
            play();
            return;
        }// end function

        function frame1()
        {
            stop();
            this.buttonum.addEventListener(MouseEvent.MOUSE_DOWN, this.mb2);
            this.buttonm.addEventListener(MouseEvent.MOUSE_DOWN, this.mb1);
            return;
        }// end function

        function frame3()
        {
            gotoAndPlay(2);
            return;
        }// end function

    }
}
