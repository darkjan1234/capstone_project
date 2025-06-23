using System.Collections.Generic;
using Abp;
using Business.Solutions.Chat.Dto;
using Business.Solutions.Dto;

namespace Business.Solutions.Chat.Exporting
{
    public interface IChatMessageListExcelExporter
    {
        FileDto ExportToFile(UserIdentifier user, List<ChatMessageExportDto> messages);
    }
}
