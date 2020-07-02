package PP_KT_34_fla
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;

    dynamic public class Symbol3_44 extends MovieClip
    {
        public var patreonbutt:SimpleButton;

        public function Symbol3_44()
        {
            addFrameScript(0, this.frame1, 8, this.frame9);
            return;
        }// end function

        public function mouseDownHandlerPatb(event:MouseEvent) : void
        {
            navigateToURL(new URLRequest("https://www.patreon.com/peachypop34"), "_blank");
            return;
        }// end function

        function frame1()
        {
            stop();
            return;
        }// end function

        function frame9()
        {
            stop();
            this.patreonbutt.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandlerPatb);
            return;
        }// end function

    }
}
