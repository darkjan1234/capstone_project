namespace Business.Solutions.Notifications.Dto
{
    public class SetNotificationAsReadOutput
    {
        public bool Success { get; set; }

        public SetNotificationAsReadOutput(bool success)
        {
            Success = success;
        }
    }
}
