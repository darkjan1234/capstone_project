using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Business.Solutions.PTT;
using Abp.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Authorization;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Web.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PttController : AbpController
    {
        private readonly IPttService _pttService;

        public PttController(IPttService pttService)
        {
            _pttService = pttService;
        }



        [HttpPost("save-audio-base64")]
        public async Task<IActionResult> SaveAudioBase64([FromBody] SaveAudioBase64Request request)
        {
            try
            {
                var audioPath = await _pttService.SaveAudioFromBase64(
                    request.AudioData,
                    request.SenderId,
                    request.ReceiverId,
                    request.GroupId,
                    request.DurationSeconds);

                return Ok(new { success = true, audioPath });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("group-messages/{groupId}")]
        public async Task<IActionResult> GetGroupMessages(int groupId, int skipCount = 0, int maxResultCount = 20)
        {
            try
            {
                var messages = await _pttService.GetGroupMessages(groupId, skipCount, maxResultCount);
                return Ok(new { success = true, data = messages });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("user-groups/{userId}")]
        public async Task<IActionResult> GetUserGroups(int userId)
        {
            try
            {
                var groups = await _pttService.GetUserGroups(userId);
                return Ok(new { success = true, data = groups });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("message/{messageId}")]
        public async Task<IActionResult> DeleteMessage(Guid messageId)
        {
            try
            {
                var result = await _pttService.DeleteAudioMessage(messageId);
                return Ok(new { success = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }



    public class SaveAudioBase64Request
    {
        [Required]
        public string AudioData { get; set; }

        [Required]
        public int SenderId { get; set; }

        public int ReceiverId { get; set; }

        [Required]
        public int GroupId { get; set; }

        [Required]
        public int DurationSeconds { get; set; }
    }
}
